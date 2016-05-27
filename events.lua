-- called from nginx.conf

local events = {}
local ffi = require('ffi')
local table = require('table')
local c = require('./c')

ffi.cdef[[

/* Return type for onRequest */
struct onRequest_return {
	char* r0;
	char* r1;
	char* r2;
};

extern struct onRequest_return onRequest(GoString p0, GoString p1, GoString p2);

extern char* onResponse(GoString p0, GoString p1, GoString p2, GoString p3);

]]

function events.on_request(uri, method, request_headers)
  -- note: apigee externs are defined in nginx.confg
  local server = ffi.load('../go/server.so')

  --convert to c
  local c_method = c.ToGoString(method)
  local c_uri = c.ToGoString(uri)
  local c_request_headers = c.ToGoString(request_headers)

  local result = server.onRequest(c_uri, c_method, c_request_headers)

  local uriResult = c.ToLua(result.r0)
  local methodResult = c.ToLua(result.r1)
  local headerResult = c.ToLua(result.r2)
  local headers = c.parse_headers(headerResult)

  --free memory
  ffi.gc(result.r0, ffi.C.free)
  ffi.gc(result.r1, ffi.C.free)
  ffi.gc(result.r2, ffi.C.free)
  -- ffi.gc(result, ffi.C.free)
  -- ffi.gc(c_method, ffi.C.free)
  -- ffi.gc(c_uri, ffi.C.free)
  -- ffi.gc(c_request_headers, ffi.C.free)

  return {
    headers = headers,
    uri = uriResult,
    method = methodResult
  }
end

function events.on_response(uri, method,requestHeaders,responseHeaders)
  local server = ffi.load('../go/server.so')

  local c_response_headers = c.ToGoString(responseHeaders)
  local c_request_headers = c.ToGoString(requestHeaders)
  local c_uri = c.ToGoString(uri)
  local c_method = c.ToGoString(method)

  local c_headers = server.onResponse(c_uri,c_method,c_request_headers,c_response_headers)

  local serializedHeaders = c.ToLua(c_headers)
  local headers = c.parse_headers(serializedHeaders)

  ffi.gc(c_headers, ffi.C.free)
  -- ffi.gc(c_uri, ffi.C.free)
  -- ffi.gc(c_method, ffi.C.free)
  -- ffi.gc(c_request_headers, ffi.C.free)
  -- ffi.gc(c_response_headers, ffi.C.free)

  return {
    headers=headers
  }
end

return events
