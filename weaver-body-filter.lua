local common = require('./weaver-common')

if not (ngx.ctx.notProxying == 1) then
  -- We could get here after a DONE or or WBOD or RBOD command
  local rid = ngx.ctx.rid
  local lastCmd = ngx.ctx.lastCommand
  local writingBody = false
  local readingBody = ngx.ctx.readingBody

  if lastCmd == 'RBOD' then
    ngx.ctx.readingBody = true
    readingBody = true
    ngx.ctx.lastCommand = nil
  elseif lastCmd == 'WBOD' then
    writingBody = true
  end

  if readingBody then
    -- We got an RBOD command at some point, so every single chunk has
    -- to go to the go code.
    local body = ngx.arg[1]
    local bodyLen
    if body == nil then
      bodyLen = 0
    else
      bodyLen = string.len(body)
    end
    local last = 0
    if ngx.arg[2] then
      last = 1
    end

    gobridge.GoSendResponseBodyChunk(rid, last, body, bodyLen)
  end

  if writingBody then
    -- Don't forget to replace the body if we are writing it.
    ngx.arg[1] = nil
  end

  if ngx.arg[2] then
    -- Right now we only read the response body on the last chunk.
    -- Doing otherwise would require a different Go API.
    if not (lastCmd == 'DONE' or lastCmd == 'ERRR') then
      local newBody = {}
      local newIndex = 0
      if writingBody then
        local chunk = common.getChunk(ngx.ctx.nextWriteChunk)
        table.insert(newBody, chunk)
      end

      local cmdBuf
      repeat
        cmdBuf = common.pollResponseCommand(rid)
        local cmd = string.sub(cmdBuf, 0, 4)
        if cmd == 'WBOD' then
          writingBody = true
          local chunk = common.getChunk(string.sub(cmdBuf, 5))
          table.insert(newBody, chunk)
        end
      until cmd == 'DONE' or cmd == 'ERRR'

      if writingBody then
        ngx.arg[1] = newBody
      end
    end
    -- Otherwise status was DONE or WERR and we are DONE

    -- This is run on all responses at the end, so this is when we free up the
    -- go request context
    gobridge.GoFreeResponse(ngx.ctx.rid)
    gobridge.GoFreeRequest(ngx.ctx.id)
  end
end
