local window = js.global
local console = js.global.console
local reactive = require "reactive.base"

local counter, set_counter = reactive.create_signal(0)

reactive.create_effect(function()
    console:log("Counter: ", counter())
    window.document:getElementById("counter").innerText = counter()
end)

function window.increment_counter()
    set_counter(counter() + 1)
end
