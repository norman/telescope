--- Telescope is a test library for Lua that allows for flexible, declarative tests.
-- For information, please visit the project homepage at:
-- <a href="http://telescope.luaforge.net/">http://telescope.luaforge.net</a>.
-- @release 0.1
module('telescope', package.seeall)

--- The status codes that can be returned by an invoked test. These should not be overidden.
-- @name status_codes
-- @class table
-- @field err - This is returned when an invoked test results in an error
-- rather than a passed or failed assertion.
-- @field fail - This is returned when an invoked test contains one or more failing assertions.
-- @field pass - This is returned when all of a test's assertions pass.
-- @field pending - This is returned when a test does not have a corresponding function.
-- @field unassertive - This is returned when an invoked test does not produce
-- errors, but does not contain any assertions.
status_codes = {
  err         = 2,
  fail        = 4,
  pass        = 8,
  pending     = 16,
  unassertive = 32
}

--- Labels used to show the various <tt>status_codes</tt> as a single character.
-- These can be overidden if you wish.
-- @name status_labels
-- @class table
-- @see status_codes
-- @field status_codes.err         'E'
-- @field status_codes.fail        'F'
-- @field status_codes.pass        'P'
-- @field status_codes.pending     '?'
-- @field status_codes.unassertive 'U'
status_labels = {
  [status_codes.err]         = 'E',
  [status_codes.fail]        = 'F',
  [status_codes.pass]        = 'P',
  [status_codes.pending]     = '?',
  [status_codes.unassertive] = 'U'
}

--- The default names for context blocks. It defaults to "context", "spec" and
-- "describe." You can override this table to create your own custom name for
-- contexts.
-- @name context_aliases
-- @class table
context_aliases = {"context", "describe", "spec"}
--- The default names for test blocks. It defaults to "test," "it", "expect" and
-- "should." You can override this table to create your own custom name for
-- tests.
-- @name test_aliases
-- @class table
test_aliases    = {"test", "it", "expect", "should"}

before_aliases  = {"before", "setup"}
after_aliases  = {"after", "teardown"}

-- Prefix to place before all assertion messages. Used by make_assertion().
assertion_message_prefix  = "Assert failed: expected "

--- The default assertions.
-- These are the assertions built into telescope. You can override them or
-- create your own custom assertions using <tt>make_assertion</tt>.
-- <ul>
-- <tt><li>assert_nil(a)</tt> - true if a is nil</li>
-- <tt><li>assert_blank(a)</tt> - true if a is nil, or the empty string</li>
-- <tt><li>assert_empty(a)</tt> - true if a is an empty table</li>
-- <tt><li>assert_equal(a, b)</tt> - true if a == b</li>
-- <tt><li>assert_match(a, b)</tt> - true if b is a string that matches pattern a</li>
-- <tt><li>assert_greater_than(a, b)</tt> - true if a > b</li>
-- <tt><li>assert_less_than(a, b)</tt> - true if a < b</li>
-- <tt><li>assert_gte(a, b)</tt> - true if a >= b</li>
-- <tt><li>assert_lte(a, b)</tt> - true if a <= b</li>
-- <tt><li>assert_not_nil(a)</tt> - true if a is not nil</li>
-- <tt><li>assert_not_blank(a)</tt>  - true if a is not nil and a is not the empty string</li>
-- <tt><li>assert_not_empty(a)</tt> - true if a is a table, and a is not empty</li>
-- <tt><li>assert_not_equal(a, b)</tt> - true if a ~= b</li>
-- <tt><li>assert_not_match(a, b)</tt> - true if the string b does not match the pattern a</li>
-- <tt><li>assert_not_greater_than(a, b)</tt> - true if not (a > b)</li>
-- <tt><li>assert_not_less_than(a, b)</tt> - true if not (a < b)</li>
-- <tt><li>assert_not_gte(a, b)</tt> - true if not (a >= b)</li>
-- <tt><li>assert_not_lte(a, b)</tt> - true if not (a <= b)</li>
-- </ul>
-- @see make_assertion
-- @name assertions
-- @class table
assertions = {}

--- Create a custom assertion.
-- This creates an assertion along with a corresponding negative assertion. It
-- is used internally by telescope to create the default assertions.
-- @param name The base name of the assertion.
-- <p>
-- The name will be used as the basis of the positive and negative assertions;
-- i.e., the name <tt>equal</tt> would be used to create the assertions
-- <tt>assert_equal</tt> and <tt>assert_not_equal</tt>.
-- </p>
-- @param message The base message that will be shown.
-- <p>
-- The assertion message is what is shown when the assertion fails.  It will be
-- prefixed with the string in <tt>telescope.assertion_message_prefix</tt>.
-- The variables passed to <tt>telescope.make_assertion</tt> are interpolated
-- in the message string using <tt>string.format</tt>.  When creating the
-- inverse assertion, the message is reused, with <tt>" to be "</tt> replaced
-- by <tt>" not to be "</tt>. Hence a recommended format is something like:
-- <tt>"%s to be similar to %s"</tt>.
-- </p>
-- @param func The assertion function itself.
-- <p>
-- The assertion function can have any number of arguments.
-- </p>
-- @usage <tt>make_assertion("equal", "%s to be equal to %s", function(a, b)
-- return a == b end)</tt>
-- @see assertions
function make_assertion(name, message, func)
  local neg_message = string.gsub(message, " to be ", " not to be ")
  local function format_message(message, ...)
    local a = {}
    for _, v in ipairs({...}) do
      table.insert(a, tostring(v))
    end
    return string.format(assertion_message_prefix .. message, unpack(a))
  end
  assertions["assert_" .. name] = function(...)
    if assertion_callback then assertion_callback(...) end
    if not func(...) then
      error({format_message(message, ...), debug.traceback()})
    end
  end
  assertions["assert_not_" .. name] = function(...)
    if assertion_callback then assertion_callback(...) end
    if func(...) then
      error({format_message(neg_message, ...), debug.traceback()})
    end
  end
end

--- Return a table with table t's values as keys and keys as values.
local function invert_table(t)
  t2 = {}
  for k, v in pairs(t) do t2[v] = k end
  return t2
end

-- Truncate a string "s" to length "len", optionally followed by the string
-- given in "after" if truncated; for example, truncate_string("hello world",
-- 3, "...")
local function truncate_string(s, len, after)
  if string.len(s) <= len then
    return s
  else
    local s = string.gsub(string.sub(s, 1, len), "%s*$", '')
    if after then return s .. after else return s end
  end
end

local function filter(t, f)
  local a, b
  return function()
    repeat a, b = next(t, a)
      if not b then return end
      if f(a, b) then return a, b end
    until not b
  end
end

local function ancestors(i, contexts)
  if i == 0 then return end
  local a = {}
  local function func(j)
    if contexts[j].parent == 0 then return nil end
    table.insert(a, contexts[j].parent)
    func(contexts[j].parent)
  end
  func(i)
  return a
end

make_assertion("nil",          "'%s' to be nil",                           function(a) return a == nil end)
make_assertion("blank",        "'%s' to be blank",                         function(a) return a == '' or a == nil end)
make_assertion("empty",        "'%s' to be an empty table",                function(a) return not next(a) end)
make_assertion("equal",        "'%s' to be equal to '%s'",                 function(a, b) return a == b end)
make_assertion("match",        "'%s' to be a match for %s",                function(a, b) return string.match(b, a) end)
make_assertion("greater_than", "'%s' to be greater than '%s'",             function(a, b) return a > b end)
make_assertion("less_than",    "'%s' to be less than '%s'",                function(a, b) return a < b end)
make_assertion("gte",          "'%s' to be greater than or equal to '%s'", function(a, b) return a >= b end)
make_assertion("lte",          "'%s' to be less than or equal to '%s'",    function(a, b) return a <= b end)

--- Build a contexts table from the test file given in <tt>path</tt>.
-- If the optional <tt>contexts</tt> table argument is provided, then the
-- resulting contexts will be added to it.
-- <p>
-- The resulting contexts table's structure is as follows:
-- </p>
-- <code>
-- {
--   {0, "this is a context"},
--   {1, "this is a nested context"},
--   {2, "this is a test", func},
--   {2, "this is another test", func},
--   {0, "this is test outside any context"},
-- }
-- </code>
-- <p>
-- In other words, a context table is a list of tables. Each table's first
-- value is the index of the value's parent context. If the index is 0, then it
-- lies outside of any context. Each table's second value is its name. If the
-- table has a third value, then the table represents a test and the third
-- value is the test to be run.
-- </p>
-- @param contexts A optional table in which to collect the resulting contexts
-- and function.
function load_contexts(path, contexts)

  local env = getfenv()
  local current_index = 0
  local context_table = contexts or {}

  local function context_block(name, func)
    table.insert(context_table, {parent = current_index, name = name, context = true})
    local previous_index = current_index
    current_index = #context_table
    func()
    current_index = previous_index
  end

  local function test_block(name, func)
    local test_table = {name = name, func = func}
    table.insert(context_table, {parent = current_index, name = name, test = func or true})
  end

  local function before_block(func)
    context_table[current_index].before = func
  end

  local function after_block(func)
    context_table[current_index].after = func
  end

  for _, v in ipairs(after_aliases) do env[v] = after_block end
  for _, v in ipairs(before_aliases) do env[v] = before_block end
  for _, v in ipairs(context_aliases) do env[v] = context_block end
  for _, v in ipairs(test_aliases) do env[v] = test_block end

  local func = loadfile(path)
  setfenv(func, env)
  func()
  return context_table

end

--- Run all tests.
-- This function will exectute each function in the contexts table, and add the
-- following fields to its corresponding table:
-- <ul>
-- <li>status_code - the test status code</li>
-- <li>status_label - the label for the status_code</li>
-- <li>message - a table with an error message and stack trace, if the test
-- failed or produced an error.</li>
-- </ul>
-- @param contexts The contexts created by <tt>load_contexts</tt>.
-- @param callbacks A table of callback functions to be invoked before or after
-- various test states.
-- <p>
-- There is a callback for each test <tt>status_code</tt>.
-- Valid callbacks are:
-- </p>
-- <ul>
-- <li>after - will be invoked after each test</li>
-- <li>before - will be invoked before each test</li>
-- <li>err - will be invoked after each test which results in an error</li>
-- <li>fail - will be invoked after each failing test</li>
-- <li>pass - will be invoked after each passing test</li>
-- <li>pending - will be invoked after each pending test</li>
-- <li>unassertive - will be invoked after each test which doesn't assert
-- anything</li>
-- </ul>
-- <p>
-- Callbacks could be used, for example, to drop into a debugger upon a failed
-- expectation or error, for profiling, or updating a GUI progress meter.
-- </p>
-- @return A table with the following fields:
-- <ul>
-- <li>assertions - assertion count</li>
-- <li>errors - error count</li>
-- <li>failures - failure count</li>
-- <li>passes - passed test count</li>
-- <li>pendings - pending count</li>
-- <li>tests - test count</li>
-- <li>unassertive - unassertive test count</li>
-- <li>contexts - the context table passed as an argument to <tt>run</tt>.</li>
-- </ul>
-- @see load_contexts
-- @see status_codes
function run(contexts, callbacks)

  local results = {}
  local env = getfenv()
  local status_names = invert_table(status_codes)

  for k, v in pairs(assertions) do
    setfenv(v, env)
    env[k] = v
  end

  local function invoke_callback(name, test)
    if not callbacks then return end
    if type(callbacks[name]) == "table" then
      for _, c in ipairs(callbacks[name]) do c(test) end
    elseif type(callbacks[name]) == "function" then
      callbacks[name](test)
    end
  end

  local function invoke_test(func)
    local assertions_invoked = 0
    env.assertion_callback = function()
      assertions_invoked = assertions_invoked + 1
    end
    setfenv(func, env)
    local result, message = pcall(func)
    if result and assertions_invoked > 0 then
      return status_codes.pass, assertions_invoked, nil
    elseif result then
      return status_codes.unassertive, 0, nil
    elseif type(message) == "table" then
      return status_codes.fail, assertions_invoked, message
    else
      return status_codes.err, assertions_invoked, {message, debug.traceback()}
    end
  end

  for i, v in filter(contexts, function(i, v) return v.test end) do
    local result = { test = i, status_code = status_codes.pending }
    local ancestors = ancestors(i, contexts)
    table.sort(ancestors)
    -- this "before" is the test callback passed into the runner
    invoke_callback("before", v)
    -- this "before" is the "before" block in the test.
    for _, a in ipairs(ancestors) do
      if contexts[a].before then contexts[a].before() end
    end
    -- check if it's a function because pending tests will just have "true"
    if type(v.test) == "function" then
      result.status_code, result.assertions_invoked, result.message = invoke_test(v.test)
      invoke_callback(status_names[status_code], result)
    else
      invoke_callback("pending", v.test)
    end
    for _, a in ipairs(ancestors) do
      if contexts[a].after then contexts[a].after() end
    end
    invoke_callback("after", result)
    result.status_label = status_labels[result.status_code]
    results[i] = result
  end

  return results

end

--- Show a detailed report for each context, with the status of each test.
function test_report(contexts, results)

  local level                = 0
  local previous_level       = 0
  local buffer               = {}
  local width                = 80
  local status_format        = "[%s]"
  local status_format_len    = 3
  local context_name_format  = "%-" .. width - status_format_len .. "s"
  local function_name_format = "%-" .. width - status_format_len .. "s"
  local leading_space        = "  "
  local line_char            = "-"

  local function space()
    return string.rep(leading_space, level - 1)
  end

  local function add_divider()
    table.insert(buffer, string.rep(line_char, width))
  end

  for i, item in ipairs(contexts) do
    local ancestors = ancestors(i, contexts)
    previous_level = level or 0
    level = #ancestors
    -- the 4 here is the length of "..." plus one space of padding
    local name = truncate_string(item.name, width - status_format_len - 4 - #ancestors, '...')
    if previous_level ~= level and level == 0 then add_divider() end
    if item.context then
      if level == 0 then add_divider() end
      table.insert(buffer, string.format(context_name_format, space() .. name .. ':'))
    else
      table.insert(buffer, string.format(function_name_format, space() .. name) ..
        string.format(status_format, results[i].status_label))
    end
  end
  add_divider()
  return table.concat(buffer, "\n")

end

--- Show stack traces for tests which produced a failure or an error.
function error_report(results)
  local buffer = {}
  function report_on_context(c)
    for i, v in ipairs(c) do
      local name = v.name
      if v.context then -- output a context label
        report_on_context(v.context)
      elseif v.message then -- this is a test with an error
        table.insert(buffer, v.name .. ":\n" .. v.message[1] .. "\n" .. v.message[2])
      end
    end
  end
  report_on_context(results.contexts)
  return table.concat(buffer, "\n")
end

--- Show a one-line report with the status counts. The counts given are: total
-- tests, assertions, passed tests, failed tests, pending tests, and tests which
-- didn't assert anything.
function summary_report(results)
  return string.format(
    "%d tests, %d assertions, %d passed, %d failed, %d errors, %d pending, %d unassertive",
    results.tests, results.assertions, results.passes, results.failures,
    results.errors, results.pendings, results.unassertives)
end
