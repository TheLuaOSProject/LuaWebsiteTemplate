local window = js.global
local console = js.global.console
local document = js.global.document

function window.say_hi()
    console:log("Hi!")
    document:querySelector("h1").textContent = "Hi from lua!"
end
