local gozerian = {}
function gozerian.init(handlers)
  gobridge = require('gozerian-init')

  for key,value in pairs(handlers) do
    local cfgErr = gobridge.GoCreateHandler(key, value)
    if not (cfgErr == nil) then
      local errMsg = ffi.string(cfgErr)
      print('Error loading configuration: ' .. errMsg)
      ffi.C.free(cfgErr)
      return
    end
  end

  return gobridge
end
return gozerian
