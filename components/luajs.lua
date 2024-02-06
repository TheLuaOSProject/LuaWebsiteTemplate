local xml_gen = require("xml-generator")
local xml = xml_gen.xml

return xml_gen.component(function ()
    coroutine.yield(xml.script {
        type="text/javascript",
        src="luajs.js"
    })

    --JS 🤮🤮🤮
    coroutine.yield(xml.script {type="text/javascript"} [[
        Module.newState().then(async (L) => { await L.enableLuaScriptTags(document); });
    ]])

    coroutine.yield(xml.script {type="text/lua"} [[
        package.path="/?.lua;/?/init.lua;/?.lua;/?/init.lua;"..package.path
    ]])
end)
