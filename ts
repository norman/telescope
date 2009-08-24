#!/usr/bin/env lua
require 'luarocks.require'
require 'telescope'

local contexts = {}
for i, v in pairs(arg) do
	if i > 0 then
    telescope.load_specs(arg[i], contexts)
	end
end

local results = telescope.run(contexts)
print(telescope.full_report(results))
