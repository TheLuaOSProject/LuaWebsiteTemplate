local window = js.global
local console = js.global.console
local document = js.global.document

local mod = require("module")

function window.say_hi()
    console:log("Hi!")
    document:querySelector("h1").textContent = "Hi from lua! Here is the result of module add: "..mod.add(3, 3)
end
