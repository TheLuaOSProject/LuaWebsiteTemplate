---@diagnostic disable: undefined-global

local bootstrap = require("components.css-frameworks.bootstrap")
local header = require("components.header")

return html {charset="utf8"} {
    header {title="Hello, World!", css_framework=bootstrap} {
        script {type="text/lua", src="index.lua"};
    };

    body {
        h1 {class="text-center"} "Reactivity test";
        main {class="container"} {
            button {onclick="increment_counter()", class="btn btn-primary", id="counter"} "0";
        };
    };
}
