---@diagnostic disable: undefined-global

local header = require("components.header")

return html {charset="utf8"} {
    header {title="Hello, World!", css_framework=require("components.css-frameworks.tailwind")} {
        script {type="text/lua", src="index.lua"};
    };

    body {
        div {id="root"};
    };
}
