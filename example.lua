-- The following are valid test blocks for Telescope:

-- 1. Contexts and nested contexts
context("A context", function()
  before(function() end)
  after(function() end)
  context("A nested context", function()
    test("A test", function()
      assert_not_equal("ham", "cheese")
    end)
    context("Another nested context", function()
      test("Another test", function()
        assert_greater_than(2, 1)
      end)
    end)
  end)
  test("A test in the top-level context", function()
    assert_equal(1, 1)
  end)
end)


-- 2. Tests with no context.
test("A test with no context", function()
end)

test("Another test with no context", function()
end)

-- 3. Context and blocks and tests with various aliases

spec("This is a context", function()
  describe("This is another context", function()
    it("this is a test", function()
    end)
    expect("this is another test", function()
    end)
    should("this is another test", function()
    end)
  end)
end)
