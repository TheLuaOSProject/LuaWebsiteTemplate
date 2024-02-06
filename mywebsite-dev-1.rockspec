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
   "lua 5.4",
   "luaxmlgenerator >= 1.0.0",
   "luafilesystem",
   "penlight",
   "pegasus"
}
build = {
   type = "command",
   build_command = "./lua scripts/build.lua"
}
