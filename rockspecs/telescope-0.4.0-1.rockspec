package = "telescope"
version = "0.4.0-1"
source = {
   url = "http://cloud.github.com/downloads/norman/telescope/telescope-0.4.0.tar.gz",
   md5 = "c69c6c99e2d9738bab1f3bd941831536"
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
