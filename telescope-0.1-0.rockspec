package = "telescope"
version = "0.1-0"
source = {
   url = "http://example.org/archive.tgz",
}
description = {
   summary = "A test/spec library for Lua.",
   detailed = [[
      Telescope is an in-progress test/spec library for Lua.
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
    },
    bin = {
      "ts"
    }
  }
}
