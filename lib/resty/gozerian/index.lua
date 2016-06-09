local gozerian = {}
local gobridge
function gozerian.init()
  gobridge = require('./lib/resty/gozerian/init-weaver')
end

function gozerian.body_filter()
  require('./lib/resty/gozerian/weaver-body-filter')
end

function gozerian.process_request()
  require('./lib/resty/gozerian/weaver-request')
end
function gozerian.header_filter()
  require('./lib/resty/gozerian/weaver-header-filter')
end

return gozerian