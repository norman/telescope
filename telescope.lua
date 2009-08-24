module('telescope', package.seeall)

status_codes = {
  fail    = 2,
  pass    = 4,
  pending = 8,
  err     = 16,
  empty   = 32
}

status_labels = {
  [status_codes.fail]    = 'F',
  [status_codes.pass]    = 'P',
  [status_codes.pending] = ' ',
  [status_codes.err]     = 'E',
  [status_codes.empty]   = '?'
}

context_aliases = {"context", "describe"}
test_aliases = {"test", "it", "spec", "should"}

assertions = {}

--- Create an assertion.
function make_assertion(name, message, func)
  local prefix  = "Assert failed: expected "
  local neg_message = string.gsub(message, " to be ", " not to be ")
  local function format_message(message, ...)
    local a = {}
    for _, v in ipairs({...}) do
      table.insert(a, tostring(v))
    end
    return string.format(prefix .. message, unpack(a))
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

local function invert_table(t)
  t2 = {}
  for k, v in pairs(t) do t2[v] = k end
  return t2
end

local function truncate_string(s, len, after)
  if string.len(s) <= len then
    return s
  else
    local s = string.gsub(string.sub(s, 1, len), "%s*$", '')
    if after then return s .. after else return s end
  end
end

local function copy_global_env()
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return new_table
  end
  return _copy(_G)
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

function load_specs(path, specs)

  local env = copy_global_env()
  local current_context = specs or {}

  local function context(name, func)
    local new = {}
    table.insert(current_context, {name = name, context = new})
    local previous_context = current_context
    current_context = new
    func()
    current_context = previous_context
  end

  local function test(name, func)
    local test_table = {name = name, func = func}
    table.insert(current_context, test_table)
  end

  for _, v in ipairs(context_aliases) do env[v] = context end
  for _, v in ipairs(test_aliases) do env[v] = test end

  local spec = loadfile(path)
  setfenv(spec, env)
  spec()
  return current_context

end

-- Run tests
function run(contexts, callbacks)

  local results = {
    tests        = 0,
    assertions   = 0,
    errors       = 0,
    passes       = 0,
    failures     = 0,
    pendings     = 0,
    empties      = 0,
    contexts     = contexts
  }

  local env = copy_global_env()
  local status_names = invert_table(status_codes)

  env.assertion_callback = function()
    results.assertions = results.assertions + 1
  end
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
    results.tests = results.tests + 1
    setfenv(func, env)
    local old_assertions = results.assertions
    local result, message = pcall(func)
    if result and old_assertions < results.assertions then
      results.passes = results.passes + 1
      return status_codes.pass
    elseif result then
      results.empties = results.empties + 1
      return status_codes.empty
    elseif type(message) == "table" then
      results.failures = results.failures + 1
      return status_codes.fail, message
    else
      results.errors = results.errors  + 1
      return status_codes.err, {message, debug.traceback()}
    end
  end

  local function run_tests(context)
    for _, v in ipairs(context) do
      if v.context then
        run_tests(v.context)
      else
        invoke_callback("before")
        if not v.func then
          results.pendings = results.pendings + 1
          v.status_code = status_codes.pending
          invoke_callback("pending", v)
        else
          v.status_code, v.message = invoke_test(v.func)
          invoke_callback(status_names[v.status_code], v)
        end
        invoke_callback("after", v)
      end
    end
  end

  run_tests(contexts)
  return results

end

function full_report(results)

  local level                = 0
  local buffer               = {}
  local errors               = {}
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


  function report_on_context(c)
    for i, v in ipairs(c) do
      if not v.test and level == 0 then -- this is a root context
        table.insert(buffer, string.rep(line_char, width))
      end
      -- the 4 here is the length of "..." plus one space of padding
      local name = truncate_string(v.name, width - status_format_len - 4 - level, '...')
      if v.context then -- output a context label
        table.insert(buffer, string.format(context_name_format, space() .. name .. ':'))
        level = level + 1
        report_on_context(v.context)
        level = level - 1
      else -- this is a test
        table.insert(buffer, string.format(function_name_format, space() .. name) ..
          string.format(status_format, status_labels[v.status_code]))
        if v.message then
          table.insert(errors, v.name .. ":\n" .. v.message[1] .. "\n" .. v.message[2])
        end
      end
    end
  end

  report_on_context(results.contexts)
  table.insert(buffer, string.rep("-", width))
  table.insert(buffer, string.format("%d tests, %d assertions, %d passed, %d failed, %d pending, %d unassertive\n",
    results.tests, results.assertions, results.passes, results.failures, results.pendings, results.empties))
  table.insert(buffer, table.concat(errors, "\n"))
  return table.concat(buffer, "\n")

end
