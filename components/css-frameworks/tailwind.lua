-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local xml_gen = require("xml-generator")
local xml = xml_gen.xml

return xml_gen.component(function(args)
    ---@type string[]
    local plugins = (args.plugins or {})

    local url_str = "https://cdn.tailwindcss.com"
    if #plugins > 0 then
        url_str = url_str.."?plugins="..table.concat(plugins, ",")
    end

    return xml.script {
        src=url_str;
    }
end)
