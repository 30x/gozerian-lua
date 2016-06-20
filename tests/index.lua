local ngx = {}
describe("index construction", function()
  package.path = package.path .. ";./lib/resty/gozerian/?.lua"
  local index  = require('lua-gozerian')
  it('init',function()
    index.init()
  end)

  it('body',function()
    index.body_filter()
  end)

  it('header',function()
    index.header_filter()
  end)
  it('request',function()
    index.process_request()
  end)
end)