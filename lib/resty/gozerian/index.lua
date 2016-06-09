local gozerian = {}
local gobridge
function gozerian.init()
  gobridge = require('lib.init-weaver')
end

function gozerian.body_filter()
  require('lib.weaver-body-filter')
end

function gozerian.process_request()
  require('lib.weaver-request')
end
function gozerian.header_filter()
  require('lib.weaver-header-filter')
end

return gozerian