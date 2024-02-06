-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

---<head> with bootstrap dependencies.

local xml_gen = require("xml-generator")
local luajs = require("components.luajs")
local xml = xml_gen.xml

return xml_gen.component(function (args, kids)
    local title = assert(args.title) --[[@as string]]
    local css_framework = args.css_framework --[[@as XML.Component?]]

    return xml.head {
        xml.title {title};
        xml.meta {
            name="viewport",
            content="width=device-width, initial-scale=1"
        };
        kids;
        luajs;
        css_framework;
    }
end)
