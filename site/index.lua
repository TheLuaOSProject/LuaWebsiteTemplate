local window = js.global

local react = require "reactive"

function window.say_hi(id)
    local elem = window.document:getElementById(id)
    elem.innerHTML = tostring(react.get_some_html())
end
