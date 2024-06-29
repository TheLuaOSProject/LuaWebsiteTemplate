package = "server"
version = "dev-1"
source = {
   url = "git+https://github.com/Frityet/LuaWebsiteTemplate"
}
description = {
   homepage = "https://github.com/Frityet/LuaWebsiteTemplate",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "lapis",
   "luaxmlgenerator",
   "penlight"
}
build = {
   type = "builtin",
   modules = {

   }
}
