require("plugin")

local function processString(input)
    -- Function to replace content inside f-string
    local function replaceContent(content)
        -- Replace '{' and '}'
        content = content:gsub("{", '"..(')
        content = content:gsub("}", ').."')

        return content
    end

    -- Pattern to find f-strings
    local pattern = 'f"(.-)"'

    -- Process each f-string
    local output = input:gsub(pattern, function(match)
        -- First, replace escaped quotes with a placeholder
        match = match:gsub('\\"', '\0')

        -- Replace the contents inside braces
        match = replaceContent(match)

        -- Restore escaped quotes
        return '("' .. match:gsub('\0', '\\"') .. '")'
    end)

    return output
end

local f = assert(io.open("t.lua", "rb"))

local text = f:read("*a")
print(processString(text))
-- local diffs = OnSetText("t.lua", text)
-- if not diffs then os.exit(1) end

-- for _, diff in ipairs(diffs) do
--     text = text:sub(1, diff.start - 1) .. diff.text .. text:sub(diff.finish + 1)
-- end

-- print(text)

f:close()
