-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

---<head> with bootstrap dependencies.

local xml_gen = require("xml-generator")
local xml = xml_gen.xml

return xml_gen.component(function (args)
    local title = assert(args.title) --[[@as string]]

    return xml.head {
        xml.title {title};
        xml.meta {
            name="viewport",
            content="width=device-width, initial-scale=1"
        };
        xml.link {
            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css",
            rel="stylesheet",
            integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN",
            crossorigin="anonymous"
        };
        xml.script {
            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js",
            integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL",
            crossorigin="anonymous"
        };
    }
end)
