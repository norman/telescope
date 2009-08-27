#!/usr/bin/env lua
require 'luarocks.require'
require 'telescope'
require 'std'

local function getopt(arg, options)
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub(v, 1, 2) == "--" then
      local x = string.find(v, "=", 1, true)
      if x then tab[string.sub(v, 3, x - 1)] = string.sub(v, x + 1)
      else tab[string.sub(v, 3)] = true
      end
    elseif string.sub(v, 1, 1) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while (y <= l) do
        jopt = string.sub(v, y, y)
        if string.find(options, jopt, 1, true) then
          if y < l then
            tab[jopt] = string.sub(v, y + 1)
            y = l
          else
            tab[jopt] = arg[k + 1]
          end
        else
          tab[jopt] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end

local callbacks = {}

local function progress_meter(t)
  io.stdout:write(t.status_label)
end

local function show_usage()
  local text = [[
Telescope v 0.1

Usage: ts [options] [files]

Description:
  Telescope is a test framework for Lua that allows you to write tests
  and specs in a TDD or BDD style.

Options:

  -f,     --format=full     Show full report format
  -h,-?   --help            Show this text

An example test:

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

Project home:
  http://telescope.luaforge.net/

License:
  MIT/X11 (Same as Lua)

Author:
  Norman Clarke <norman@njclarke.com>. Please feel free to email bug
  reports, feedback and feature requests.
]]
  print(text)
end

local function add_callback(callback, func)
  if callbacks[callback] then
    if type(callbacks[callback]) ~= "table" then
      callbacks[callback] = {callbacks[callback]}
    end
    table.insert(callbacks[callback], func)
  else
    callbacks[callback] = func
  end
end

local function process_args()
  local files = {}
  local opts = getopt(arg, "")
  local i = 1
  for _, _ in pairs(opts) do i = i+1 end
  while i <= #arg do table.insert(files, arg[i]) ; i = i + 1 end
  return opts, files
end
local opts, files = process_args()
if opts["h"] or opts["?"] or opts["help"] or not (next(opts) or next(files)) then
  show_usage()
  os.exit()
end

-- set callbacks passed on command line
local callback_args = { "after", "before", "err", "fail", "pass",
  "pending", "unassertive"}
for _, callback in ipairs(callback_args) do
  if opts[callback] then
    add_callback(callback, loadstring('return ' .. opts[callback])())
  end
end

local contexts = {}
for _, file in ipairs(files) do
  telescope.load_contexts(file, contexts)
end

local results = telescope.run(contexts, callbacks)
local buffer = {}

if opts.format == "full" or opts.f then
  table.insert(buffer, telescope.test_report(contexts, results))
  table.insert(buffer, telescope.summary_report(contexts, results))
  table.insert(buffer, "")
  table.insert(buffer, telescope.error_report(contexts, results))
else
  table.insert(buffer, telescope.summary_report(contexts, results))
  table.insert(buffer, "")
  table.insert(buffer, telescope.error_report(contexts, results))
end

print(table.concat(buffer, "\n"))
os.exit()


