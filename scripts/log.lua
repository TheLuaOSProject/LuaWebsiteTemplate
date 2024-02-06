-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local export = {}

local pretty = require("pl.pretty")

-- local l_tostring = tostring
-- ---@param v any
-- ---@return string
-- local function tostring(v)
--     if type(v) == "table" then
--         local mt = getmetatable(v)
--         if mt and mt.__tostring then
--             return tostring(v)
--         else
--             return pretty.write(v)
--         end
--     else
--         return l_tostring(v)
--     end
-- end

function export.info(...)
    local time = os.date("%H:%M:%S")
    io.write("\x1b[36m["..time.." - \x1b[32minfo\x1b[36m]\x1b[0m ")
    for i = 1, select("#", ...) do
        io.write(tostring(select(i, ...)))
    end
    io.write("\x1b[0m\n")
end

function export.warning(...)
    local time = os.date("%H:%M:%S")
    io.write("\x1b[36m["..time.." - \x1b[33mwarning\x1b[36m]\x1b[33m ")
    for i = 1, select("#", ...) do
        io.write(tostring(select(i, ...)))
    end
    io.write("\x1b[0m\n")
end

function export.error(...)
    local time = os.date("%H:%M:%S")
    io.write("\x1b[36m["..time.." - \x1b[31merror\x1b[36m]\x1b[31m ")
    for i = 1, select("#", ...) do
        io.write(tostring(select(i, ...)))
    end
    io.write("\x1b[0m\n")
end

return export
