local f = require("fmt")

function string.print(...) return print(...) end;

f"{#arg > 0 and \"args:\" or \"\"} {table.concat(arg, ', ')}":print()
