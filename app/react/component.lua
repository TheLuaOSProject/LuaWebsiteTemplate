-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local insert = table.insert

---@generic T: table
---@param x T
---@param copy_metatable boolean?
---@return T
local function deep_copy(x, copy_metatable)
    local tname = type(x)
    if tname == "table" then
        local new = {}
        for k, v in pairs(x) do
            new[k] = deep_copy(v, copy_metatable)
        end

        if copy_metatable then setmetatable(new, deep_copy(getmetatable(x), true)) end

        return new
    else return x end
end

---@class React.Component : XML.Node
---@field attributes { [string] : any } The attributes can be any type for `component`s, but not for `node`s
---@field context fun(args: { [string] : any }, children: XML.Children?): fun(): XML.Node
local component_metatable = {
    ---@param self React.Component
    ---@param args { [string] : any, [integer] : XML.Children }
    __call = function (self, args)
        ---@type React.Component
        local new = setmetatable({
            attributes = deep_copy(self.attributes, true),
            children = deep_copy(self.children or {}, true),
            context = self.context
        }, getmetatable(self))

        if type(args) == "table" and not (getmetatable(args) or {}).__tostring then
            for k, v in pairs(args) do
                if type(k) == "number" then
                    insert(new.children, v)
                else
                    new.attributes[k] = v
                end
            end
        else
            insert(new.children, args)
        end

        return new
    end;

    __name = "React.Component";
}

---@param ctx fun(args: { [string] : any }, children: XML.Children?): fun(): XML.Node
---@return React.Component
return function (ctx)
    return setmetatable({
        attributes = {},
        children = {},
        context = ctx
    }, component_metatable)
end
