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

function gozerian.body_filter()
  require('gozerian-body-filter')
end

function gozerian.process_request()
  require('gozerian-request')
end
function gozerian.header_filter()
  require('gozerian-header-filter')
end

return gozerian