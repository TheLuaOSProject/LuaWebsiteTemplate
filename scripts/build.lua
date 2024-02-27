#!/usr/bin/env ./lua
local vernum = _VERSION:match("%d+%.%d+")
package.path = string.format("?.lua;?/init.lua;lua_modules/share/lua/%s/?.lua;lua_modules/share/lua/%s/?/init.lua;", vernum, vernum)..package.path
package.cpath = string.format("lua_modules/lib/lua/%s/?.so;lua_modules/lib/lua/%s/?/init.so;", vernum, vernum)..package.cpath

local xml_gen = require("xml-generator")
local Path = require("scripts.path-utilities")
local log = require("scripts.log")

local cwd = Path.current_directory
local site_dir = cwd/"site"
local build_dir = cwd/"build"
local luajs_dir = cwd/"LuaJS"
local luajs_build_dir = build_dir/"luajs"

--turn off GC, its too slow, and the OS cleans up the memory after anyways
collectgarbage("stop")

---This is for when there is file watching, and we only want to compile one file
---@type Path
local file_to_compile do
    if arg[1] then
        file_to_compile = Path.new(arg[1])
        if not file_to_compile:exists() then
            return
        end
        if file_to_compile:is_absolute() then file_to_compile = assert(file_to_compile:relative_to(cwd)) end
    end
end

---Type annotation stuff
---@diagnostic disable: lowercase-global
lua = _G
yield = coroutine.yield
xml = xml_gen.xml
---@diagnostic enable: lowercase-global

---@param x XML.Node
---@return string
local function html_document(x) return "<!DOCTYPE html>"..tostring(x) end

---@param type string
---@return fun(dir: Path)
local function compiler_for(type)
    return function(dir)
        for file in dir:find(type..".lua") do
            local fname = assert(file:relative_to(site_dir))
            -- local out_file = build_dir/assert(fname:relative_to(cwd))
            local out_file = (build_dir/fname):remove_extension():add_extension("html")
            log.info("Compiling \x1b[34m"..tostring(file:relative_to(cwd)).."\x1b[0m to \x1b[34mbuild/"..tostring(out_file:relative_to(build_dir)).."\x1b[0m")
            yield()
            ---@type fun(): XML.Node
            local gen_fn = assert(loadfile(tostring(file), "t", setmetatable({ require = require, yield = yield, xml = xml_gen.xml }, { __index = xml_gen.xml })))
            yield()

            local gen = gen_fn()
            yield()

            if not out_file:parent_directory():exists() then assert(out_file:parent_directory():create_directory(true)) end
            local f = assert(out_file:open("file", "w+b")) --[[@as file*]]
            f:write(gen and html_document(gen) or "")
            f:close()
            yield()
        end
    end
end

---@param type string
---@return fun(dir: Path)
local function copier_for(type)
    return function(dir)
        for file in dir:find(function(p) return p:extension() == type end) do
            local fname = assert(file:relative_to(site_dir))
            local out_file = build_dir/fname
            log.info("Copying \x1b[34m"..tostring(file:relative_to(cwd)).."\x1b[0m to \x1b[34mbuild/"..tostring(out_file:relative_to(build_dir)).."\x1b[0m")
            yield()
            if not out_file:parent_directory():exists() then assert(out_file:parent_directory():create_directory(true)) end
            yield()


            assert(file:copy_to(out_file))
            yield()
        end
    end
end

log.info("Site directory: ", site_dir)
log.info("Build directory: ", build_dir)
log.info("LuaJS directory: ", luajs_dir)

if not luajs_build_dir:exists() then
    build_dir:create_directory(true)
    --I know this is unsafe
    --i dont care
    local cmd = "git submodule update --init --recursive"
    log.info("$ "..cmd)
    assert(os.execute(cmd))

    cmd = "cd "..tostring(luajs_dir).." && git reset --hard && git pull origin main && npm install && npm run clean && npm run build INSTALL_DEST="..tostring(luajs_build_dir)
    log.info("$ "..cmd)
    assert(os.execute(cmd))
end

if file_to_compile then
    local ext = assert(file_to_compile:extension())
    print(ext)
else
    local threads = {
        coroutine.create(compiler_for "html"),
        coroutine.create(compiler_for "css"),
        coroutine.create(copier_for "lua"),
        coroutine.create(copier_for "html"),
        coroutine.create(copier_for "js"),
    }

    for _, thread in ipairs(threads) do coroutine.resume(thread, site_dir) end

    local failed = 0
    local done = false
    while not done do
        done = true
        for _, thread in ipairs(threads) do
            if coroutine.status(thread) ~= "dead" then
                done = false
                local ok, error = coroutine.resume(thread)
                if not ok then
                    log.error(error)
                    failed = failed + 1
                end
            end
        end
    end

    if failed > 0 then
        log.warning(failed.." files failed to compile or copy")
    end
end
