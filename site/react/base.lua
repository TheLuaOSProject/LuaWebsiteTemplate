-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local window = js.global

--[[
Based off https://github.com/ekwoka/bricks-to-rocketships/blob/main/src/fine-grained/signal.ts
]]
---@class reactive.base
local export = {
    ---@type function[]
    context = {}
}

---@param fn function
function export.create_effect(fn)
    export.context[#export.context+1] = fn
    fn()
    export.context[#export.context] = nil
end

local queued, reaction_queue = false, {}

---@generic T
---@param value T
---@return (fun(): T) get, (fun(new: T | fun(a: T): T): nil) set, function[] effects
function export.create_signal(value)
    ---@type function[]
    local effects = {}

    local function set(new_value)
        value = type(new_value) == "function" and new_value(value) or new_value

        for _, effect in ipairs(effects) do effect() end
        if queued then return end
        queued = true

        window:queueMicrotask(function()
            for _, effect in ipairs(reaction_queue) do effect() end
            queued = false
            reaction_queue = {}
        end)
    end

    local function get()
        if export.context[#export.context] then
            effects[#effects+1] = export.context[#export.context]
        end
        return value
    end

    return get, set, effects
end

return export
