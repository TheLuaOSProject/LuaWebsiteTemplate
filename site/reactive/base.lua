-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

--[[
Based off https://dev.to/siddharthshyniben/implementing-reactivity-from-scratch-51op
]]
---@class reactive.base
local reactive = {}

---@class reactive.base.Subscription
---@field execute fun(): nil
---@field dependencies reactive.base.Subscription[][]

---@type reactive.base.Subscription[]
local context = {}

---@param running reactive.base.Subscription
---@param subscriptions reactive.base.Subscription[]
local function subscribe(running, subscriptions)
    table.insert(subscriptions, running)
    table.insert(running.dependencies, subscriptions)
end

---@generic T
---@param value T
---@return (fun(): T) get, (fun(val: T)) set
function reactive.create_signal(value)
    local subscriptions = {}
    local function read()
        local running = context[#context]
        if running then
            subscribe(running, subscriptions)
        end
        return value
    end
    local function write(next_value)
        value = next_value
        for _, sub in ipairs(subscriptions) do
            sub:execute()
        end
    end
    return read, write
end

---@param running reactive.base.Subscription
local function cleanup(running)
    for _, dep in ipairs(running.dependencies) do
        for i, v in ipairs(dep) do
            if v == running then
                table.remove(dep, i)
                break
            end
        end
    end
    running.dependencies = {}
end

---@param fn fun(): nil
function reactive.create_effect(fn)
    local effect = {
        execute = function(effect)
            cleanup(effect)
            table.insert(context, effect)
            fn()
            table.remove(context)
        end,
        dependencies = {}
    }
    effect:execute()
end

---@generic T
---@param fn fun(): T
---@return fun(): T
function reactive.create_memo(fn)
    local get, set = reactive.create_signal(nil)
    reactive.create_effect(function()
        set(fn())
    end)
    return get
end

return reactive
