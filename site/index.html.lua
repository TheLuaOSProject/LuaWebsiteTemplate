---@diagnostic disable: undefined-global

local bootstrap_head = require("components.bootstrap-head")

return html {charset="utf8"} {
    bootstrap_head {title="Hello, World!"};

    body {
        h1 {class="text-center"} "Fritsite";

        script {type="text/lua"} [[
            local window = js.global

            local counter = 0
            local function increment()
                local counter_elem = window.document:getElementById("counter")
                counter = counter + 1
                counter_elem.innerHTML = counter
            end

            local function decrement()
                local counter_elem = window.document:getElementById("counter")
                counter = counter - 1
                counter_elem.innerHTML = counter
            end

            window.increment = increment
            window.decrement = decrement
        ]];

        main {class="container"} {
            p {id="counter"} "0";
            button {onclick="increment()"} "Increment";
            button {onclick="decrement()"} "Decrement";
        };
    };
}
