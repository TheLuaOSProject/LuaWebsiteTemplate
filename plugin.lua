---@class Diff
---@field start  integer The number of bytes at the beginning of the replacement
---@field finish integer The number of bytes at the end of the replacement
---@field text   string  What to replace

---@param  uri  string The uri of file
---@param  text string The content of file
---@return Diff[]?
function OnSetText(uri, text)
    local diffs = {}

    local function processString(fString, startIdx)
        -- Replace the content within curly braces
        local modifiedString = fString:gsub("%b{}", function(curlyContent)
            local curlyInner = curlyContent:sub(2, -2) -- Extract the content inside {}.
            return "\".." .. curlyInner .. "..\""
        end)

        -- Remove the surrounding quotes and wrap with f(...)
        modifiedString = "f(" .. modifiedString:sub(3, -2) .. ")"

        if modifiedString ~= fString then
            return {
                start = startIdx,
                finish = startIdx + #fString - 1,
                text = modifiedString
            }
        end
    end

    -- Pattern to match f-strings.
    for startIdx, quoteChar, innerContent in text:gmatch("()f(['\"])(.-)%2()") do
        local fString = "f" .. quoteChar .. innerContent .. quoteChar
        local diff = processString(fString, startIdx)
        if diff then
            table.insert(diffs, diff)
        end
    end

    return diffs
end
