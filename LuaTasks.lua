require "tlua"

local function docs()
  tlua.invoke("clean")
  os.execute("luadoc -d docs --nomodules telescope.lua")
end

local function clean()
  os.execute("rm -rf docs")
end

local function spec()
  os.execute("tsc spec/*.lua")
end

tlua.task("docs", "Run Luadoc for the project", docs)
tlua.task("clean", "Clean up project directory", clean)
tlua.task("spec", "Run specs", spec)
tlua.default_task = "spec"
