
describe("a test", function()
  -- tests go here

  -- tests
  it("checks c struct req", function()
    local events = require("../events")
    local headers = "X-MyHeader-key1: val1\nX-MyHeader-key2: val2\nX-MyHeader-key3: val3"

    local res = events.on_request('http://someuri','PUT',headers);
    assert.is_equal(res.headers['X-MyHeader-key1'][1], 'modifiedval1')
    assert.is_equal(res.headers['X-MyHeader-key2'][1], 'modifiedval2')

  end)

   -- tests
  it("checks c struct res", function()
    local events = require("../events")
    local c = require("../c")

    local response_headers = {}
    response_headers["X-MyHeader-key1"]={}
    response_headers["X-MyHeader-key1"][1] = 'val1'
    local request_headers = "X-MyHeader-key1: val1\nX-MyHeader-key2: val2\nX-MyHeader-key3: val3"
    local response_headers_serialized = c.serialize_headers(response_headers)
    local res = events.on_response('http://someuri','PUT',response_headers_serialized,request_headers)
    local ret_response_headers = res.headers
    assert.is_equal(ret_response_headers["X-MyHeader-key1"][1],'val1')
    assert.is_equal(ret_response_headers["X-Response-Newheader"][1],'mytestval1')

  end)

  -- tests
  it("checks c struct with weird maps", function()
    local events = require("../events")
    local headers = "X-MyHeader-key1: val1,val2\nX-MyHeader-key2: val3,val4\nX-MyHeader-key3: val3"

    local res = events.on_request('http://someuri','PUT',headers);

    assert.is_equal(res.headers['X-MyHeader-key1'][1], 'modifiedval1')
    assert.is_equal(res.headers['X-MyHeader-key2'][1], 'modifiedval3')

  end)

end)