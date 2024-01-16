#!/usr/bin/env luvit
-- Copyright (c) 2023 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

os.execute("./build.lua")

local vernum = _VERSION:match("%d+%.%d+")
package.path = string.format("?.lua;?/init.lua;lua_modules/share/lua/%s/?.lua;lua_modules/share/lua/%s/?/init.lua;", vernum, vernum)..package.path
package.cpath = string.format("lua_modules/lib/lua/%s/?.so;lua_modules/lib/lua/%s/?/init.so;", vernum, vernum)..package.cpath

local Path = require("Path")
local config = require("config")
local http = require("http")
local url = require("url")

local build_dir = Path.new(config.location)

http.createServer(function (req, res)
    local path = build_dir/assert(req.url)
    if path:type() == "directory" then path = path/"index.html" end

    if path:type() == "file" then
        local mime = "text/"..(path:extension() or "plain")
        res:setHeader("Content-Type", mime)
        res:finish(assert(path:read_all()))
    else
        res:setStatus(404)
        res:finish("Not Found")
    end
end):listen(config.port, config.host, function ()
    p(string.format("Listening on http://%s:%d", config.host, config.port))
end)

