local gozerian = {}
function gozerian.init()
  gobridge = require('gozerian-init')
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