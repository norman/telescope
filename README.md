# Telescope #

A highly customizable test library for Lua that allows for declarative
tests with nested contexts. Telescope is fairly full-featured despite
being only about 250 lines of code.

## An Example ##

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
        assert_equal(3, 1)
      end)
    end)

## Getting it ##

Telescope is in early beta, but is usable. I am using it for several
personal projects.

You can use Luarocks to install the latest release from the [git repository](http://github.com/norman/telescope):

    sudo luarocks build telescope --from=http://luarocks.luaforge.net/rocks-cvs/

If you want to work on the source code, you can clone the git repository from:

    git://github.com/norman/telescope.git


## Running your tests ##

Telescope currently comes with a very basic command-line test runner,
called "ts", which is installed by Luarocks. Simply run:

    ts my_test_file.lua

Or perhaps

    ts test/*.lua

The standard full test output from the examples given would be:

    ------------------------------------------------------------------------
    A context:
    A nested context:
      A test                                                             [P]
      Another nested context:
        Another test                                                     [P]
    A test in the top-level context                                      [F]
    ------------------------------------------------------------------------
    A test with no context                                               [U]
    Another test with no context                                         [U]
    ------------------------------------------------------------------------
    This is a context:
    This is another context:
      this is a test                                                     [U]
      this is another test                                               [U]
      this is another test                                               [U]
    ------------------------------------------------------------------------
    8 tests 2 passed 3 assertions 1 failed 0 errors 5 unassertive 0 pending

    A test in the top-level context:
    Assert failed: expected '3' to be equal to '1'
    stack traceback:
      ./telescope.lua:128: in function 'assert_equal'
      example.lua:18: in function <example.lua:17>
      [C]: in function 'pcall'
      ./telescope.lua:322: in function 'invoke_test'
      ./telescope.lua:346: in function 'run'
      ./ts:129: in main chunk
      [C]: ?


Telescope tells you which tests were run, how many assertions they called,
how many passed, how many failed, how many produced errors, how many provided
a name but no implementation, and how many didn't assert anything. In the event
of any failures or errors, it shows you stack traces.

You can customize the test output to be as verbose or silent as you want, and easily
write your own test reporters - the source is well documented.

You can see all the available command-line options by running

    ts -h

### More Examples ###

    -- Tests can be outside of contexts, if you want
    test("A test with no context", function()
    end)

    test("Another test with no context", function()
    end)

    -- Contexts and tests with various aliases
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

### Even More Examples ###

    -- change the name of your test or context blocks if you want something
    -- different
    telescope.context_aliases = {"specify"}
    telescope.test_aliases = {"verify"}

    -- create your own assertions
    telescope.make_assertion("longer_than", "%s to be longer than %s chars",
      function(a, b) return string.len(a) > b end)
    -- creates two assertions: assert_longer_than and assert_not_longer_than,
    -- which give error messages such as:
    -- Assertion error: expected "hello world" to be longer than 25 chars
    -- Assertion error: expected "hello world" not to be longer than 2 chars

    -- create a test runner with callbacks to show progress and
    -- drop to a debugger on errors
    local contexts = telescope.load_contexts(file)
    local results = telescope.run(contexts, {
     after = function(t) io.stdout:write(t.status_label) end,
     error = function(t) debug.debug() end
    })

## Author ##

[Norman Clarke](mailto:norman@njclarke.com)

Please feel free to email me bug reports or feature requests.

## Acknowledgements

Telescope's initial beta release was made on Aug 25, 2009 - the 400th anniversary
of the invention of the telescope.

Thanks to [ScrewUnit](http://github.com/nathansobo/screw-unit/tree/master),
[Contest](http://github.com/citrusbyte/contest) and
[Luaspec](http://github.com/mirven/luaspec/) for inspiration.

Thanks to [Eric Knudtson](http://twitter.com/vikingux) for helping me come up with the
name "Telescope."

## License ##

The MIT License

Copyright (c) 2009 [Norman Clarke](mailto:norman@njclarke.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
