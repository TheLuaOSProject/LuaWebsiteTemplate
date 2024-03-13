#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static int l_add(lua_State *L) {
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);
    return 1;
}

static const struct luaL_Reg LIBRARY[] = {
    {"add", l_add},
    {NULL, NULL}
};

int luaopen_module(lua_State *L) {
    luaL_newlib(L, LIBRARY);
    return 1;
}

