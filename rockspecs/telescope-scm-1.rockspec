package = "telescope"
version = "scm-1"
source = {
   url = "git://github.com/norman/telescope.git",
}
description = {
   summary = "A test/spec library for Lua.",
   detailed = [[
      Telescope is a test/spec library for Lua.
   ]],
   license = "MIT/X11",
   homepage = "http://telescope.luaforge.net"
}
dependencies = {
   "lua >= 5.1"
}

build = {
  type = "none",
  install = {
    lua = {
      "telescope.lua",
    },
    bin = {
      "tsc"
    }
  }
}
