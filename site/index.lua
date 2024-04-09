-- Copyright (c) 2024 Amrit Bhogal
--
-- This software is released under the MIT License.
-- https://opensource.org/licenses/MIT

local document = js.global.document

local react = require("react")
local xml_gen = require("xml-generator")
react.dom.inject(document:getElementById("root"), require("App"))
