# Lua Website Template

Do you HATE HTML?
Do you also HATE JS?

Do YOU love a small, fast, ergonomic, and simple language developed in Brazil in 1993?

Then this is the template for you! This template lets you write websites written in Lua!

## Dependencies

### Minimum
- [Luarocks](https://luarocks.org/)
- Lua 5.4
- Git
- [LuaJS](https://github.com/Doridian/LuaJS) dependencies (for client-side lua code execution):
    - [NPM](https://www.npmjs.com/)
    - [Emscripten](https://emscripten.org/)

## Usage

Add `.html.lua` files to [site/](site/). These will be compiled/served as HTML files. You can also add `.css`, `.html`, `.lua` and `.js` files to [site/](site/). and they will just be copied over to the output directory.

Run `luarocks init` and `luarocks make` to install the development files. You can then use `./luarocks-client` to install dependencies that will be able to be used on the browser, and `./luarocks-server` (or just `./luarocks`) to install dependencies that would be used on the server.

### Development server

To run the development server, first you must install luahttp by doing `./luarocks-server install http`, then run `./lua scripts/serve.lua` in the root directory. This will start a server on port 8123. You can change the port by editing [config.lua](config.lua).

## Writing HTML

[See the LuaXMLGenerator documentation](https://github.com/Frityet/LuaXMLGenerator/blob/master/README.md)
