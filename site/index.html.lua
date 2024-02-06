---@diagnostic disable: undefined-global

local bootstrap = require("components.css-frameworks.bootstrap")
local header = require("components.header")

return xml {charset="utf8"} {
    header {title="Hello, World!", css_framework=bootstrap};

    body {
        h1 {class="text-center"} "Fritsite";
        main {class="container"} {
            p "Hello, World!"
        };
    };
}
