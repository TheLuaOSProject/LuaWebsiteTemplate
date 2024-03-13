local xml_gen = require("xml-generator")
local xml = xml_gen.xml

return xml_gen.component(function ()
    yield(xml.script {
        type="module",
        src="./luajs.mjs",
    })

    --JS 🤮🤮🤮
    yield(xml.script {type="module"} [[
        import emscriptenInit from './luajs.mjs';

        (await emscriptenInit()).newState().then(async (L) => {
            await L.enableLuaScriptTags(document);
        });
    ]])
end)
