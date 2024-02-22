---@diagnostic disable: undefined-global

local bootstrap = require("components.css-frameworks.bootstrap")
local header = require("components.header")

return html {charset="utf8"} {
    header {title="Hello, World!", css_framework=bootstrap} {
        script {type="text/lua", src="index.lua"};
    };

    body {
        h1 {class="text-center"} "Your website";
        main {class="container"} {
            p "Hello, World!";
            button {onclick="say_hi()", class="btn btn-primary"} "Say hi";
        };
    };
}
