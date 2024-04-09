-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT
local xml_gen = require("xml-generator")
local xml = xml_gen.xml
local react = require("react")

return react.component(function()
    local i, set_i = react.base.create_signal(0)

    return function()
        return xml.main { class = "container mx-auto" } {
            xml.h1 { class = "text-4xl text-center" } "Hello, World!",
            xml.p { "I = ", i() },
            xml.button "Increment" {
                onclick = function()
                    set_i(i() + 1)
                end,
                class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            },
        }
    end
end)
