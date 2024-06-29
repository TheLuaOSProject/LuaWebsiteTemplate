variables = {
   LUA_DIR           = "LuaJS/lua",
   LUA_INCDIR        = "LuaJS/lua",
   LUA_LIBDIR        = "LuaJS/build/luajs",
   LUA_LIBDIR_FILE   = "luajs.wasm",
   LIB_EXTENSION     = "wasm",

   CC                = "emcc",
   CXX               = "em++",
   LD                = "emcc",
   CFLAGS            = "-fblocks -O2 -s WASM -s SIDE_MODULE -s ASYNCIFY",
   LIBFLAG           = "-s WASM -s SIDE_MODULE -s ASYNCIFY",
   AR                = "emar",
   RANLIB            = "emranlib",
   STRIP             = "emstrip",
   MAKE              = "emmake make",
}
