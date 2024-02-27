local xml_gen = require("xml-generator")
local pretty = require("pl.pretty")
local xml = xml_gen.xml

local export = {}

---@return XML.Node
function export.get_some_html()
    return xml.div {
        xml.p "Here is some pl pretty:";
        xml.pre(pretty.write {
            a = 1,
            b = 2,
            c = 3
        })
    }
end

return export
