-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local window = js.global
local document = js.global.document
local console = js.global.console

local node2js = require("react.node2js")
local react = require("react.base")
local xml_gen = require("xml-generator")

---@class react.dom
local export = {
    ---@type (fun(): XML.Node)?
    contents = nil,

    ---@type js.Element?
    root = nil,
}

function export.update()
    if export.contents == nil or export.root == nil then return end

    ---@type js.Element
    local new_dom = export.root:cloneNode(false)
    for _, element in ipairs(node2js(export.contents)) do
        new_dom:appendChild(element)
    end

    export.root:replaceWith(new_dom)
    export.root = new_dom
end

---@param elem js.Element
---@param contents React.Component
function export.inject(elem, contents)
    export.contents = contents.context(contents.attributes, contents.children)
    export.root = elem

    react.create_effect(function()
        export.update()
    end)
end

return export
