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
   homepage = "http://norman.github.com/telescope"
}
dependencies = {
   "lua >= 5.1"
   "penlight >= 0.9.0"
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
