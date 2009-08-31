require 'telescope'

local i = 0

context("A context", function()

  before(function() i = i + 1 end)
  after(function() i = i - 1 end)

  context("A nested context", function()

    test("A passing test", function()
      assert_true(true)
    end)

    test("A failing test", function()
      assert_true(false)
    end)

    test("An unassertive test", function()
      local hello = "world"
    end)

    test("A test that causes an error", function()
      t.hello = "world"
    end)

    test("A pending test")

    context("A deeply nested context", function()
    end)

  end)

end)

test("A test in the top level")
