describe("Telescope spec", function()

  local contexts

  context("Syntax", function()

    before(function()
      contexts = telescope.load_contexts("spec/fixtures/syntax.lua")
    end)

    context("contexts and tests", function()

      it("should have names", function()
        assert_equal("A context", contexts[1].name)
        assert_equal("A passing test", contexts[3].name)
      end)

      it("should have parents", function()
        for i, c in ipairs(contexts) do
          assert_gte(c.parent, 0)
        end
      end)

      it("should have a parent of 0 when at the top level", function()
        assert_equal("A context", contexts[1].name)
        assert_equal(0, contexts[1].parent)
        assert_equal("A test in the top level", contexts[9].name)
        assert_equal(0, contexts[9].parent)
      end)

    end)

    context("contexts", function()

      it("can have contexts as children", function()
        assert_equal("A nested context", contexts[2].name)
        assert_equal(1, contexts[2].parent)
      end)

      it("can have tests as children", function()
        assert_equal("A nested context", contexts[3].context_name)
        assert_equal("A passing test", contexts[3].name)
      end)

      it("can have a 'before' function", function()
        assert_type(contexts[1].before, "function")
      end)

      it("can have an 'after' function", function()
        assert_type(contexts[1].after, "function")
      end)

    end)

    context("tests", function()

      it("when pending, should have true for the 'test' field", function()
        assert_equal("A pending test", contexts[7].name)
        assert_true(contexts[7].test)
      end)

      it("when non-pending, should have a function for the 'test' field", function()
        assert_equal("A test that causes an error", contexts[6].name)
        assert_equal("function", type(contexts[6].test))
      end)

    end)

  end)

end)
