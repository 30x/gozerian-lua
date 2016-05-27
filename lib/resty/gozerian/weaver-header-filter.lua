local c = require('./c')
local common = require('./weaver-common')

function setResponseHeaders(headers)
  local lower_headers = {}
  for k,v in pairs(headers) do
    ngx.header[k] = v
    lower_headers[string.lower(k)] = v
  end
  for k,v in pairs(ngx.header) do
    if not lower_headers[k] then
      -- print('deleting ' .. k)
      ngx.header[k] = nil
    end
  end
end

function setStatus(status)
  ngx.status = status
end

if ngx.ctx.notProxying == 1 then
  -- Replace the headers send back as part of the generated response
  if not (ngx.ctx.responseHeaders == nil) then
    setResponseHeaders(ngx.ctx.responseHeaders)
  end
  -- Let nginx compute the content length
  ngx.header['Content-Length'] = nil

else
  -- If we get here then we have the result of a proxy_pass.
  -- Run the response path here.
  local id = ngx.ctx.id
  local rid = ngx.ctx.rid

  local outHdrs = c.serialize_headers(ngx.header)
  gobridge.GoBeginResponse(rid, id, ngx.status, outHdrs)

  local cmd
  local cmdBuf
  repeat
    cmdBuf = common.pollResponseCommand(rid)
    cmd = string.sub(cmdBuf, 0, 4)
    if cmd == 'ERRR' then
      -- Perhaps there is something better to do here?
      print('Error from go code on response path: ', string.sub(cmdBuf, 5))
      ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    elseif cmd == 'WSTA' or cmd == 'SWCH' then
      setStatus(string.sub(cmdBuf, 5))
    elseif cmd == 'WHDR' then
      local h = c.parse_headers(string.sub(cmdBuf, 5))
      setResponseHeaders(h)
    elseif cmd == 'WBOD' then
      ngx.ctx.nextWriteChunk = string.sub(cmdBuf, 5)
      -- Let nginx compute the content length
      ngx.header['Content-Length'] = nil
    elseif cmd == 'RBOD' then
      -- Because we might write the body after reading it
      ngx.header['Content-Length'] = nil
    elseif cmd == 'DONE' then
      ngx.ctx.commandsDone = true
    end
  until cmd == 'DONE' or cmd == 'ERRR' or cmd == 'WBOD' or cmd == 'RBOD'

  ngx.ctx.lastCommand = cmd
end
