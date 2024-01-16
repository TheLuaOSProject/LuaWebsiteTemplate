---@diagnostic disable: undefined-global

local bootstrap_head = require("components.bootstrap-head")

return html {charset="utf8"} {
    bootstrap_head {title="Hello, World!"};

    body {
        h1 {class="text-center"} "Fritsite";

        main {class="container"} {
        };
    };
}
