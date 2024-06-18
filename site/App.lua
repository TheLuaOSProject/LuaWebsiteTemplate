-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local window = js.global

local xml_gen = require("xml-generator")
local xml = xml_gen.xml
local react = require("react")
local yield = coroutine.yield


---@class TodoItem
---@field title string
---@field completed boolean
---@field due_date string

local todo_item = react.component(function(props)
    ---@type TodoItem
    local item = assert(props.item)
    ---@type fun(new: TodoItem?)
    local onchange = assert(props.onchange)

    return function ()
        -- should be spaced out more
        return xml.div {class="flex items-center p-2 border-b-2 border-gray-300"} {
            xml.input {
                type = "checkbox",
                checked = item.completed,
                onchange = function (e)
                    onchange {
                        title = item.title,
                        completed = e.target.checked,
                        due_date = item.due_date
                    }
                end
            };
            xml.div {class="flex-grow p-2"} {
                xml.span {class=item.completed and "line-through" or nil}(item.title);
                xml.br;
                xml.div {class="flex items-center"} {
                    xml.input {
                        type = "date",
                        value = item.due_date,
                        onchange = function (e)
                            onchange {
                                title = item.title,
                                completed = item.completed,
                                due_date = e.target.value
                            }
                        end
                    };

                    function ()
                        local current_date = os.date("%Y-%m-%d")
                        if item.due_date < current_date then
                            yield(xml.span {class="text-red-500"} "Overdue")
                        end
                    end
                }
            },

            xml.button {
                onclick = function ()
                    onchange(nil)
                end;
                class = "p-2 bg-red-500 text-white rounded-lg"
            } "Delete"
        }
    end
end)

return react.component(function()
    local todo_items, set_todo_items = react.use_state({} --[[ @as TodoItem[] ]])

    return function ()
        return xml.div {class="p-4"} {
            xml.h1 "Todo List";

            xml.ul {
                function ()
                    for _, item in ipairs(todo_items()) do
                        yield(xml.li {class="p-2"} {
                            todo_item {
                                item = item,
                                onchange = function (new_item)
                                    set_todo_items(function (old_items)
                                        local new_items = {}
                                        for _, old_item in ipairs(old_items) do
                                            if old_item ~= item then
                                                new_items[#new_items+1] = old_item
                                            end
                                        end

                                        if new_item then
                                            new_items[#new_items+1] = new_item
                                        end

                                        return new_items
                                    end)
                                end,
                            }
                        })
                    end
                end
            };

            xml.input {
                type = "text",
                onkeypress = function (e)
                    if e.key == "Enter" then
                        set_todo_items(function (old_items)
                            return {
                                {
                                    title = e.target.value,
                                    completed = false,
                                    due_date = os.date("%Y-%m-%d")
                                },

                                table.unpack(old_items)
                            }
                        end)

                        e.target.value = ""
                    end
                end;

                class = "border-2 border-gray-300 rounded-lg p-2"
            }
        }
    end
end)
