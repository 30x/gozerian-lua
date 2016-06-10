local common = {}

-- Go passes body data back to us in chunks that it allocates, and then
-- lets us access and requires that we free. This simplifies the Lua / C / Go
-- interface.
function common.getChunk(chunkID)
  local id = tonumber(chunkID, 16)
  local data = gobridge.GoGetChunk(id)
  local len = gobridge.GoGetChunkLength(id)
  -- Made a copy of the chunk from Go land, and then we can free it
  local chunk = ffi.string(data, len)
  gobridge.GoReleaseChunk(id)
  ffi.C.free(data)
  return chunk
end

function common.pollCommand(id)
  -- This part is peformance-critical. "GoPollRequest" does a non-blocking
  -- poll of a Go channel. That's very efficient. But there is no way to
  -- make nginx sleep and then wake it up from another thread, so we have
  -- to "sleep." The loop below adds a minimum of one millisecond latency to
  -- every call. We could optimize the selection of the wait time to make
  -- this lower.
  local cmd = gobridge.GoPollRequest(id, 0)
  while cmd == nil do
    ngx.sleep(0.001)
    cmd = gobridge.GoPollRequest(id, 0)
  end
  local ret = ffi.string(cmd)
  ffi.C.free(cmd)
  if ngx.ctx.debug then
    print('Request command: ', string.sub(ret, 0, 4))
  end
  return ret
end

function common.pollResponseCommand(rid)
  -- In the response path we can't use ngx.sleep.
  -- So we have to do a blocking response.
  local cmd = gobridge.GoPollResponse(rid, 1)
  if cmd == nil then
    return 'ERRR'
  end
  local ret = ffi.string(cmd)
  ffi.C.free(cmd)
  if ngx.ctx.debug then
    print('Response command: ', string.sub(ret, 0, 4))
  end
  return ret
end

return common
