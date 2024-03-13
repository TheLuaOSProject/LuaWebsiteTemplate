#!/usr/bin/env ./lua

local vernum = _VERSION:match("%d+%.%d+")
package.path = string.format("?.lua;?/init.lua;lua_modules/share/lua/%s/?.lua;lua_modules/share/lua/%s/?/init.lua;", vernum, vernum)..package.path
package.cpath = string.format("lua_modules/lib/lua/%s/?.so;lua_modules/lib/lua/%s/?/init.so;", vernum, vernum)..package.cpath

-- local pegasus = require("pegasus")

local HTTPServer = require("http.server")
local HTTPHeaders = require("http.headers")
local Path = require("scripts.path-utilities")
local log = require("scripts.log")
local pretty = require("pl.pretty")
local config = require("config")

---@param x string
---@return integer? index
local function has_arg(x)
    for i, v in ipairs(arg) do
        if v == x then return i end
    end
    return nil
end

---Global so type annotations work well in the .html.lua files
---@diagnostic disable: lowercase-global
lua = _G
yield = coroutine.yield
xml_gen = require("xml-generator")
xml = xml_gen.xml
---@diagnostic enable: lowercase-global

local cwd = Path.current_directory
local build_dir, src_dir = Path.new(config.build_directory), Path.new(config.source_directory)
local luarocks_modules_dir, luarocks_lib_dir = Path.new "web_modules"/"share"/"lua"/"5.4", Path.new "web_modules"/"lib"/"lua"/"5.4" --has to be 5.4

local luajs_dir = Path.current_directory/"LuaJS"
if not build_dir:exists() or has_arg("--rebuild") then
    build_dir:create_directory(true)
    --I know this is unsafe
    --i dont care
    local cmd = "git submodule update --init --recursive"
    log.info("$ "..cmd)
    assert(os.execute(cmd))

    cmd = "cd "..tostring(luajs_dir).." && git reset --hard && git pull origin main --rebase && npm install && npm run clean && npm run build INSTALL_DEST="..tostring(cwd/build_dir)
    log.info("$ "..cmd)
    assert(os.execute(cmd))
end


local not_found = xml.html {charset="utf8"} {
    xml.head {
        xml.title "404 Not Found",
        xml.meta {name="viewport", content="width=device-width, initial-scale=1"},
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
            xml.h1 {class="text-center"} "404 Not Found",
            xml.p {class="text-center"} "The page you are looking for does not exist.",
        },
    },
}

local server_error = xml_gen.component(function(args)
    local errmsg = args.error or "Unspecified error"

    return xml.html {charset="utf-8"} {
        xml.head {
            xml.title "500 Internal Server Error",

            xml_gen.style {
                [".container"] = {
                    ["margin-top"] = "5em",
                    ["margin-bottom"] = "5em"
                },

                [".text-center"] = {
                    ["text-align"] = "center"
                }
            }
        },
        xml.body {
            xml.section {class="container"} {
                xml.h1 {class="text-center"} "500 Internal Server Error",
                xml.p {class="text-center"} "An internal server error has occured.",
                xml.p {class="text-center"} { xml.code {"Error message: ", errmsg} }
            },
        },
    }
end)

---@param x XML.Node
---@return string
local function html_document(x) return "<!DOCTYPE html>\n"..tostring(x) end

---Any require call to any thing in `components` must not be cached, so that they can be reloaded
---@param x string
---@return any, unknown
local function dohtml_require(x)
    if x:sub(1, #config.components_directory) == config.components_directory then
        package.loaded[x] = nil
        return require(x)
    else
        return require(x)
    end
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
    local ok, err = loadfile(tostring(x), "t", setmetatable({
        require = dohtml_require,
        yield = yield,
        xml_gen = xml_gen,
        xml = xml_gen.xml
    }, { __index = xml_gen.xml }))
    if not ok then return nil, err end
    return ok()
end

---@param headers table
---@param status 200 | 404 | 500
local function set_status(headers, status)
    headers:append(":status", tostring(status))
end

local function show_server_error(error, headers, res)
    log.error("500 Internal Server Error: ", error)
    local doc = html_document(server_error {error=error})
    set_status(headers, 500)
    headers:append("content-type", "text/html")
    headers:append("content-length", tostring(#doc))
    res:write_headers(headers, false)
    res:write_chunk(doc, true)
end

local function handle(self, stream)
    ---@type { get: fun(self: table, path: string): string? }
    local headers = assert(stream:get_headers())

    local rawpath = headers:get ":path"
    local path = src_dir/rawpath
    local method = headers:get ":method"

    local res_headers = HTTPHeaders.new()

    if path:type() == "directory" then path = path/"index.html.lua" end
    if not path:exists() then path = path:add_extension("html.lua") end
    if not path:exists() then path = path:remove_extension():add_extension("html") end

    if not path:exists() then
        path = build_dir/rawpath
    end

    if not path:exists() then
        path = luarocks_modules_dir/rawpath
    end

    if not path:exists() then
        path = luarocks_lib_dir/rawpath
    end

    if path:exists() then
        log.info("200 OK: ", tostring(path))
        local ext = assert(path:extension(), "File has no extension")
        if ext ~= "html.lua" then
            local data, err = path:read_all()
            if data then
                res_headers:append("Content-Type", match(ext) {
                    css = "text/css",
                    js = "application/javascript",
                    mjs = "application/javascript",
                    wasm = "application/wasm",
                    default = "text/plain"
                })
                set_status(res_headers, 200)
                res_headers:append("content-length", tostring(#data))
                assert(stream:write_headers(res_headers, method == "HEAD"))
                if method ~= "HEAD" then
                    stream:write_chunk(data, true)
                end
            else show_server_error(err, res_headers, stream) end
            return
        end

        res_headers:append("content-type", "text/html")
        local page, err = dohtml(path)
        if page then
            local s = html_document(page)
            set_status(res_headers, 200)
            res_headers:append("content-length", tostring(#s))
            stream:write_headers(res_headers, method == "HEAD")
            if method ~= "HEAD" then
                stream:write_chunk(s, true)
            end
        else show_server_error(err, res_headers, stream) end
        return
    else
        local checked_str = {}
        for _, v in ipairs {src_dir/rawpath, build_dir/rawpath, luarocks_modules_dir/rawpath, luarocks_lib_dir/rawpath} do
            table.insert(checked_str, tostring(v))
        end
        log.info("404 Not Found: ", tostring(rawpath), "\nChecked: ", table.concat(checked_str, ", "))
        local doc = html_document(not_found)
        set_status(res_headers, 404)
        res_headers:append("content-type", "text/html")
        res_headers:append("content-length", tostring(#doc))
        stream:write_headers(res_headers, false)
        stream:write_chunk(doc, true)
    end
end

local server = assert(HTTPServer.listen {
    host = config.host,
    port = config.port,
    onstream = handle,
    onerror = function (server, context, op, err, errno)
        log.error("Server error: ", err)
        os.exit(1)
    end
})

assert(server:listen())
do
	local bound_port = select(3, server:localname())
	assert(io.stderr:write(string.format("Now listening on port %d\n", bound_port)))
end
-- Start the main server loop
assert(server:loop())
