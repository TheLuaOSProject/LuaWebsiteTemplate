---@diagnostic disable: lowercase-global
rockspec_format = "3.0"
package = "MyWebsite"
version = "dev-1"
source = {
   url = "git+https://github.com/Frityet/LuaWebsiteTemplate"
}
description = {
   homepage = "https://github.com/Frityet/LuaWebsiteTemplate",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "luaxmlgenerator >= 1.1.0",
   "luafilesystem",
   "penlight",
   "http"
}
build = {
   type = "command",
   build_command = "./lua scripts/build.lua"
}
