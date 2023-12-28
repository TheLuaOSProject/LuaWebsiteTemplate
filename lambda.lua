local get_locals = require("locals")

---Turns an expression like `x -> x * x` into `function (x) return x * x end`.
---@param expression string
---@return fun(...: any): any?
return function (expression)
    local locals = get_locals()

    -- Combine the locals with the global env
    local env = {}
    for k, v in pairs(_G) do env[k] = v end
    -- Locals after, so they can override globals.
    for k, v in pairs(locals) do env[k] = v end

    -- Validate input
    if not expression:match("(.+)%s*->%s*(.+)") then
        error("Invalid expression format. It should be like 'x -> x * x' or 'x, y -> x + y'")
    end

    local parameter, body = expression:match("(.+)%s*->%s*(.+)")
    local func, err = load("return function("..parameter..") return "..body.." end", "lambda", "t", env)

    if not func then error(err) else return func() end
end
