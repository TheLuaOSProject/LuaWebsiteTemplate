#!/usr/bin/env lua
-- Copyright (c) 2023 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local vernum = _VERSION:match("%d+%.%d+")
package.path = string.format("?.lua;?/init.lua;lua_modules/share/lua/%s/?.lua;lua_modules/share/lua/%s/?/init.lua;", vernum, vernum)..package.path
package.cpath = string.format("lua_modules/lib/lua/%s/?.so;lua_modules/lib/lua/%s/?/init.so;", vernum, vernum)..package.cpath

local pegasus = require("pegasus")
local Path = require("Path")
local pprint = require("pprint")

local root_dir = Path.new("build")

local do_build = true
local host, port = "127.0.0.1", "8080"

local args = arg
for i, arg in ipairs(args) do
    if arg == "--no-build" then do_build = false end
    if arg == "--port" then i, port = next(args, i) end
    if arg == "--host" then i, host = next(args, i) end
end
if do_build then os.execute("./build.lua") end


local CONFIG = {
    host = host,
    port = port,
    location = root_dir:name()
}

pprint(CONFIG)

local server = pegasus:new(CONFIG)

---@param path Path
---@return Path
local function resolve_path(path)
    local path = root_dir/path
    if path:exists() and path:type() == "file" then return path end

    if path:type() == "directory" then
        path = path/"index.html"
        if path:exists() then return path end
        path = path - 1
    end

    path = path:add_extension("html")
    if path:exists() then return path end

    return root_dir/"404.html"
end

server:start(function (request, response)
    response:addHeader('Content-Type', 'text/html')

    ---@type Path
    local path = resolve_path(Path.new(request["_path"]))

    print("Serving "..tostring(path))
    response:write(assert(path:read_all()))
end)
