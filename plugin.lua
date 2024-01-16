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
        local modifiedString = fString:gsub("%b{}", function(curlyContent)
            -- Extract the content inside {} without the curly braces
            local curlyInner = curlyContent:sub(2, -2)

            -- Return the concatenation sequence, ensuring proper handling of quotes
            return "\"..(" .. curlyInner .. ")..\""
        end)

        -- Handle the beginning and end of the fString
        modifiedString = "\"".. modifiedString:sub(3, -3) .."\""

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
        local fString = "f"..quoteChar..innerContent..quoteChar
        local diff = processString(fString, startIdx)
        if diff then
            table.insert(diffs, diff)
        end
    end

    return diffs
end
