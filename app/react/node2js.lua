-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local window = js.global
local console = js.global.console
local document = js.global.document

local xml_gen = require("xml-generator")

---@class js.Element : userdata
---@field style { [string]: string }
---@field tagName string
---@field childNodes js.Element[]
---@field appendChild fun(self: js.Element, child: js.Element): nil
---@field setAttribute fun(self: js.Element, key: string, value: string): nil
---@field removeAttribute fun(self: js.Element, key: string): nil
---@field addEventListener fun(self: js.Element, event: string, callback: fun()): nil
---@field cloneNode fun(self: js.Element, deep: boolean): js.Element
---@field replaceWith fun(self: js.Element, new: js.Element): nil
---@field replaceChild fun(self: js.Element, new: js.Element, old: js.Element): nil

---@param node XML.Node | string | fun(): XML.Node
---@return js.Element[]
local function node2js(node)
    local tname = xml_gen.typename(node)
    if tname == "XML.Node" then
        local tag = node.tag
        local props = node.attributes
        local children = node.children
        ---@type js.Element
        local element = document:createElement(tag)
        for k, v in pairs(props) do
            if k:sub(1, 2) == "on" then
                element:addEventListener(k:sub(3), v)
            elseif k == "style" then
                for stylek, stylev in pairs(v) do
                    element.style[stylek] = stylev
                end
            else
                local val do
                    if type(v) == "function" then
                        val = v()
                    elseif type(v) == "table" then
                        local mt = getmetatable(v)
                        if mt and mt.__tostring then val = v else val = table.concat(v, " ") end
                    else
                        val = v
                    end
                end

                if type(val) == "boolean" then
                    if val then
                        element:setAttribute(k, "")
                    else
                        element:removeAttribute(k)
                    end
                else
                    element:setAttribute(k, tostring(val))
                end

                -- element:setAttribute(k, type(val) == "boolean"
            end
        end
        for _, child in ipairs(children) do
            local tojses = node2js(child)
            for _, tojs in ipairs(tojses) do
                element:appendChild(tojs)
            end
        end
        return {element}
    elseif tname == "XML.Component" or tname == "React.Component" then
        --[[@cast node XML.Component]]

        ---@type js.Element
        local elem = document:createElement("div")
        elem:setAttribute("id", string.format("element-%p", node))

        local f = coroutine.create(node.context)
        local ok, res = coroutine.resume(f, node.attributes, node.children)
        if not ok then error(res) end
        for _, child in ipairs(node2js(res)) do
            elem:appendChild(child)
        end
        while coroutine.status(f) ~= "dead" do
            ok, res = coroutine.resume(f)
            if not ok then error(res) end
            for _, child in ipairs(node2js(res)) do
                elem:appendChild(child)
            end
        end

        return {elem}
    elseif tname == "function" then
        --[[@cast node fun(): XML.Node]]
        local co = coroutine.create(node)
        local elems = {}

        while coroutine.status(co) ~= "dead" do
            local ok, res = coroutine.resume(co)
            if not ok then error(res) end
            local tojses = node2js(res)
            for _, tojs in ipairs(tojses) do
                table.insert(elems, tojs)
            end
        end

        return elems
    else
        return node and {document:createTextNode(tostring(node))} or {}
    end
end

return node2js
