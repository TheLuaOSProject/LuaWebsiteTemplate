-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local base = require("react.base")

return {
    base = base,
    dom = require("react.dom"),
    component = require("react.component"),

    --react-like aliases
    use_state = base.create_signal,
    use_effect = base.create_effect,
}
