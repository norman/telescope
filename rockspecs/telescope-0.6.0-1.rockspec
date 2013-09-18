package = "telescope"
version = "0.6.0-1"
source = {
   url = "git://github.com/norman/telescope.git",
   tag = "0.6.0"
}
description = {
   summary = "A test/spec library for Lua.",
   detailed = [[
      Telescope is a test/spec library for Lua.
   ]],
   license = "MIT/X11",
   homepage = "http://github.com/norman/telescope"
}
dependencies = {
   "lua >= 5.1"
}

build = {
  type = "none",
  install = {
    lua = {
      "telescope.lua",
      ["telescope.compat_env"] = "telescope/compat_env.lua"
    },
    bin = {
      "tsc"
    }
  }
}
