.PHONY:	test spec
LUA_DIR = /usr/local
LUA_VERSION = `lua -e 'print(_VERSION:sub(5,7))'`
LUA_SHARE = $(LUA_DIR)/share/lua/$(LUA_VERSION)

.PHONY : test clean docs install uninstall

spec:
	@./tsc -f spec/*.lua

test:
	@./tsc spec/*.lua

docs: clean
	ldoc.lua -t "Telescope API Docs" telescope.lua

clean:
	rm -rf docs

install:
	@mkdir -p $(LUA_SHARE)
	cp telescope.lua $(LUA_SHARE)
	cp compat_env.lua $(LUA_SHARE)
	cp tsc $(LUA_DIR)/bin

uninstall:
	-rm $(LUA_SHARE)/telescope.lua
	-rm $(LUA_DIR)/bin/tsc
