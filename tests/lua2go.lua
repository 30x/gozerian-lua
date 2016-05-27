describe("lua struct conversions", function()
  -- tests go here
  local c = require("../c")

  -- tests
  it("check table with a table", function()
    local headers = {}
    headers[1] = {}
    headers[1][1] = 'test1val'
    headers[1][2] = 'test2val'
    local keys,vals = c.KeyValueToFlatArrays(headers)
    local arr = c.ToGoSlice(vals)
    local converted = c.GoSliceToTable(arr)
    assert.is_equal('test1val',converted[1])
    assert.is_equal('test2val',converted[2])

  end)
  -- tests
  it("check flatten", function()
    local headers = {}
    headers['key1'] = {}
    headers['key1'][1] = 'test1val'
    headers['key1'][2] = 'test2val'
    headers['key2'] = 'test3val'
    local keys,vals = c.KeyValueToFlatArrays(headers)
    assert.is_equal('key1',keys[1])
    assert.is_equal('key1',keys[2])
    assert.is_equal('key2',keys[3])
    assert.is_equal('test1val',vals[1])
    assert.is_equal('test2val',vals[2])
    assert.is_equal('test3val',vals[3])

  end)
    -- tests
  it("check table with a table mixed", function()
    local headers = {}
    headers[1] = {}
    headers[1][1] = 'test1val'
    headers[1][2] = 'test2val'
    headers[2] = 'test3val'
    local keys,vals = c.KeyValueToFlatArrays(headers)
    local arr = c.ToGoSlice(vals)
    local converted = c.GoSliceToTable(arr)
    assert.is_equal('test1val',converted[1])
    assert.is_equal('test2val',converted[2])
    assert.is_equal('test3val',converted[3])

  end)

  -- more tests pertaining to the top level
end)