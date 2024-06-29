local log = require("server.log")

local export = {}

---Executes a command, properly returning the status on failure.
---@param cmd string
---@param ... string
---@return boolean, integer
function export.execute(cmd, ...)
    local cmd = cmd .. " " .. table.concat({...}, " ")
    log.info("$ ", cmd)

    ---Lua 5.2>= return `status`, `exitcode`, `signal`
    ---Lua 5.1 just returns `exitcode`
    ---@type (true | nil | integer), nil, integer?
    local status, _, code = os.execute(cmd)
    if type(status) == "boolean" or type(status) == "nil" then
        return not not status, assert(code)
    else
        return status == 0, status
    end
end



return export
