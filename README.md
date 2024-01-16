# Lua Website Template

Do you HATE HTML?
Do you also HATE JS?

Do YOU love a small, fast, ergonomic, and simple language developed in Brazil in 1993?

Then this is the template for you! This template lets you write websites written in Lua!

## Dependencies

### Minimum
- [Luarocks](https://luarocks.org/)
- Lua >= 5.1 (recommended LuaJIT)

### Development server
- [Luvit](https://luvit.io/)

## Usage

Add `.html.lua` files to [site/](site/). These will be compiled/served as HTML files. You can also add `.css`, `.html`, `.lua` and `.js` files to [site/](site/). and they will just be copied over to the output directory.

To run the development server, run `luvit serve.lua` in the root directory. This will start a server on port 8080. You can change the port by editing [config.lua](config.lua).

## Writing HTML

[See the LuaXMLGenerator documentation](https://github.com/Frityet/LuaXMLGenerator/blob/master/README.md)
