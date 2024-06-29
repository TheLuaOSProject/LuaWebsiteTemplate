-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local document = js.global.document

local react = require("react")
react.dom.inject(document:getElementById("root"), require("App"))
