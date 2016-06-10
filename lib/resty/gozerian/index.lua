local gozerian = {}
function gozerian.init()
  gobridge = require('init-weaver')
  return gobridge
end

function gozerian.body_filter()
  require('weaver-body-filter')
end

function gozerian.process_request()
  require('weaver-request')
end
function gozerian.header_filter()
  require('weaver-header-filter')
end

return gozerian