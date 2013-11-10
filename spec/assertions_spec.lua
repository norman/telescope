describe('assertions', function()
  local M = require 'telescope'

  it('should correctly print arguments asserions', function()
    local res, err = pcall(function() assert_equal(1, 2) end)
    assert(res == false)
    assert(err[1] == "Assert failed: expected '1' to be equal to '2'")
  end)
end)
