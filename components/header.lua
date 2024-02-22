-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local xml_gen = require("xml-generator")
local xml = xml_gen.xml

return xml_gen.component(function (args, kids)
    return xml.head {
        xml.title(args.title);
        xml.meta {
            name="viewport",
            content="width=device-width, initial-scale=1"
        };
        require("components.luajs");
        kids;
        args.css_framework;
    }
end)
