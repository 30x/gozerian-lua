ffi.cdef[[
  void GoCreateHandler(const char* id, const char* configURI);
  void GoDestroyHandler(const char* id);
  unsigned int GoCreateRequest(const char* handlerID);
  unsigned int GoCreateResponse(const char* handlerID);
  void GoFreeRequest(unsigned int id);
  void GoFreeResponse(unsigned int id);
  void GoBeginRequest(unsigned int id, const char* rawHeaders);
  void GoBeginResponse(unsigned int rid, unsigned int id,
    unsigned int status, const char* rawHeaders);
  int GoStoreChunk(const void* data, unsigned int len);
  void GoReleaseChunk(int chunkID);
  void* GoGetChunk(int chunkID);
  unsigned int GoGetChunkLength(int chunkID);
  char* GoPollRequest(unsigned int id, int block);
  char* GoPollResponse(unsigned int id, int block);
  void GoSendRequestBodyChunk(
    unsigned int id, int last, const void* chunk, unsigned int len);
  void GoSendResponseBodyChunk(
    unsigned int id, int last, const void* chunk, unsigned int len);
]]
gobridge = ffi.load('libgozerian.so')

-- In the real code, we will create one handler per worker per "proxy".
-- We could do this by reading configs and even by passing them to the gateway.
local cfgErr = gobridge.GoCreateHandler('default', 'urn:weaver-proxy:unit-test')
if not (cfgErr == nil) then
  local errMsg = ffi.string(cfgErr)
  print('Error loading configuration: ', errMsg)
  ffi.C.free(cfgErr)
end

return gobridge
