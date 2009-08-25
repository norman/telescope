#!/usr/bin/env lua
require 'luarocks.require'
require 'telescope'

local contexts = {}
for i, v in pairs(arg) do
	if i > 0 then
    telescope.load_contexts(arg[i], contexts)
	end
end

local results = telescope.run(contexts, {
 after = function(t) io.stdout:write(t.status_label) end
})
print("")
print(telescope.test_report(results))
print(telescope.summary_report(results))
print(telescope.error_report(results))
