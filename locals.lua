--- Gets all local variables across all levels of the stack.
---@return { [string] : any }
return function ()
    local vars = {}
    local level = 2

    while true do
        local empty = true
        local idx = 1

        while true do
            if debug.getinfo(level) == nil then break end

            local name, value = debug.getlocal(level, idx)
            if name ~= nil then
                empty = false
                vars[name] = value
            else break end

            idx = idx + 1
        end

        if empty then break end

        level = level + 1
    end

    return vars
end
