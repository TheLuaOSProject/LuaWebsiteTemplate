#!/usr/bin/env luvit

local vernum = _VERSION:match("%d+%.%d+")
package.path = string.format("?.lua;?/init.lua;lua_modules/share/lua/%s/?.lua;lua_modules/share/lua/%s/?/init.lua;", vernum, vernum)..package.path
package.cpath = string.format("lua_modules/lib/lua/%s/?.so;lua_modules/lib/lua/%s/?/init.so;", vernum, vernum)..package.cpath

local Path = require("path-utilities")
local config = require("config")
local http = require("http")
local xml_gen = require("xml-generator")
local xml = xml_gen.xml

local build_dir, src_dir = Path.new(config.build_directory), Path.new(config.source_directory)

local not_found = xml.html {charset="utf8"} {
    xml.head {
        xml.title "404 Not Found";
        xml.meta {
            name="viewport",
            content="width=device-width, initial-scale=1"
        };
        xml.link {
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css",
            rel="stylesheet",
            integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN",
            crossorigin="anonymous"
        };
        xml.script {
            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js",
            integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL",
            crossorigin="anonymous"
        };
    };

    xml.body {
        xml.section {class="container"} {
            xml.h1 {class="text-center"} "404 Not Found";
            xml.p {class="text-center"} "The page you are looking for does not exist.";
        };
    };
}

local server_error = xml_gen.component(function(args)
    local errmsg = args.error or "Unspecified error"

    return xml.html {charset="utf-8"} {
        xml.head {
            xml.title "500 Internal Server Error";

            xml_gen.style {
                [".container"] = {
                    ["margin-top"] = "5em",
                    ["margin-bottom"] = "5em"
                },

                [".text-center"] = {
                    ["text-align"] = "center"
                }
            }
        };
        xml.body {
            xml.section {class="container"} {
                xml.h1 {class="text-center"} "500 Internal Server Error";
                xml.p {class="text-center"} "An internal server error has occured.";
                xml.p {class="text-center"} { "Details: ", xml.code {errmsg} };
            };
        };
    }
end)

---@param res luvit.http.ServerResponse
---@param msg string?
local function internal_server_error(res, msg)
    res.statusCode = 500
    local s = tostring(server_error {error=msg})
    res:setHeader("Content-Length", tostring(#s))
    res:finish(s)
end

---@param x XML.Node
---@return string
local function html_document(x) return "<!DOCTYPE html>\n"..tostring(x) end

---Any require call to any thing in `components` must not be cached, so that they can be reloaded
---@param x string
---@return any
local function dohtml_require(x)
    if x:sub(1, #"components") == "components" then
        package.loaded[x] = nil
        return require(x)
    else return require(x) end
end

---@generic TKey, TValue
---@param x TKey
---@return fun(cases: { [TKey]: TValue, default: TValue? }): TValue
local function match(x)
    return function(cases)
        local v = cases[x]
        if v then return v end
        return cases.default
    end
end

---@param x Path
---@return XML.Node?, string?
local function dohtml(x)
    if not x:exists() then return nil, "File does not exist" end
    local ok, err = loadfile(tostring(x), "t", setmetatable({ require = dohtml_require, yield = yield }, { __index = xml_gen.xml }))
    if not ok then return nil, err end
    return ok()
end

---Type annotation stuff
_G.lua = _G
_G.yield = coroutine.yield

http.createServer(function (req, res)
    local ip = tostring(req.socket:getsockname().ip)
    local path = src_dir/assert(req.url)
    print("["..ip.."] "..req.method.." "..req.url)
    if path:type() == "directory" then path = path/"index.html.lua" end
    if not path:exists() then path = path:add_extension("html.lua") end
    if not path:exists() then path = path:remove_extension():add_extension("html") end

    if not path:exists() then
        path = build_dir/req.url
        if not path:exists() then
            path = build_dir/"luajs"/req.url --luajs.data doesn't have a subdir so this has to be done like this
        end
    end

    if path:exists() then
        local ext = assert(path:extension())
        if ext ~= "html.lua" then
            local data, err = path:read_all()
            if data then
                res:setHeader("Content-Type", assert(match(ext) {
                    css = "text/css",
                    js = "text/javascript",
                    wasm = "application/wasm",
                    default = "application/octet-stream"
                }))
                res:setHeader("Content-Length", tostring(#data))
                res:finish(data)
            else internal_server_error(res, err) end
            return
        end

        res:setHeader("Content-Type", "text/html")
        local page, err = dohtml(path)
        if page then
            local s = html_document(page)
            res:setHeader("Content-Length", tostring(#s))
            res:finish(s)
        else internal_server_error(res, err) end
    else

        res.statusCode = 404
        local s = html_document(not_found)
        res:setHeader("Content-Length", tostring(#s))
        res:finish(s)
    end
end):listen(config.port, config.host, function ()
    print(string.format("Listening on http://%s:%d", config.host, config.port))
end)

