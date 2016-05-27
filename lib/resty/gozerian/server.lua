-- called from nginx.conf, knows about ngx
local server = {}

local events = require('./events')
local c = require('./c')
local uuid = require('resty.jit-uuid')

function server.on_request()
  local uuidInstance = uuid()             ---> v4 UUID (random)
  ngx.req.set_header('X-APIGEE-REQUEST-ID',uuidInstance)

  local method = ngx.req.get_method()
  local uri = ngx.unescape_uri(ngx.var.request_uri)
  local raw_headers = ngx.req.raw_header(true)

  local result = events.on_request(uri, method, raw_headers)

  set_request_headers(result.headers)

  if not result.uri == uri then
    ngx.req.set_uri(result.uri)
  end
  if not result.method == method then
    ngx.req.set_method(convertMethod(result.method))
  end
  return result;
end

function server.on_response()

  local response_headers = ngx.resp.get_headers()
  local request_headers = ngx.req.raw_header(true)
  local method = ngx.req.get_method()
  local uri = ngx.unescape_uri(ngx.var.request_uri)
  local response_headers_serialized = c.serialize_headers(response_headers)

  local result = events.on_response(uri,method,request_headers,response_headers_serialized)

  set_response_headers(result.headers)
end

function set_request_headers(headers)
  local lower_headers = {}
  for k,v in pairs(headers) do
    ngx.req.set_header(k,v)
    lower_headers[string.lower(k)] = v
  end
  for k,v in pairs(ngx.req.get_headers()) do
    if not lower_headers[k] then
      print('deleting ' .. k)
      ngx.req.set_header(k,nil)
    end
  end
end

function set_response_headers(headers)
  local lower_headers = {}
  for k,v in pairs(headers) do
    ngx.header[k] = v
    lower_headers[string.lower(k)] = v
  end
  for k,v in pairs(ngx.resp.get_headers()) do
    if not lower_headers[k] then
      print('deleting ' .. k)
      ngx.header[k] = nil
    end
  end
end

function convert_method(method)
  if upper(method) == "PUT" then
    return ngx.HTTP_PUT
  end
  if upper(method) == "GET" then
    return ngx.HTTP_GET
  end
  if upper(method) == "HEAD" then
    return ngx.HTTP_HEAD
  end
  if upper(method) == "POST" then
    return ngx.HTTP_POST
  end
  if upper(method) == "DELETE" then
    return ngx.HTTP_DELETE
  end
  if upper(method) == "OPTIONS" then
    return ngx.HTTP_OPTIONS
  end
  if upper(method) == "MKCOL" then
    return ngx.HTTP_MKCOL
  end
  if upper(method) == "COPY" then
    return ngx.HTTP_COPY
  end
  if upper(method) == "MOVE" then
    return ngx.HTTP_MOVE
  end
  if upper(method) == "PATCH" then
    return ngx.HTTP_PATCH
  end
  if upper(method) == "UNLOCK" then
    return ngx.HTTP_UNLOCK
  end
  if upper(method) == "LOCK" then
    return ngx.HTTP_LOCK
  end
  if upper(method) == "PROPFIND" then
    return ngx.HTTP_PROPFIND
  end
  if upper(method) == "PROPPATCH" then
    return ngx.HTTP_PROPPATCH
  end
  if upper(method) == "TRACE" then
    return ngx.HTTP_TRACE
  end
  return ngx.HTTP_GET;
end

return server
