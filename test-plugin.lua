require("plugin")

local f = assert(io.open("t.lua", "rb"))

local text = f:read("*a")
local diffs = OnSetText("t.lua", text)
if not diffs then os.exit(1) end

for _, diff in ipairs(diffs) do
    text = text:sub(1, diff.start - 1) .. diff.text .. text:sub(diff.finish + 1)
end

print(text)

f:close()
