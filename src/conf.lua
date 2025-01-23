function love.conf(t)
    t.console = true --para el debug
end

--Ejemplo de la sintaxis para axel
--[[

tab = {
    keyone = "first value",      -- this will be available as tab.keyone or tab["keyone"]
    ["keytwo"] = "second value", -- this uses the full syntax
}

tab = {}
tab["somekey"] = "some value" -- these two lines ...
tab.somekey = "some value"    -- ... are equivalent


----------------------

ipairs() returns index-value pairs and is mostly used for numeric tables. The non-numeric keys are ignored as a whole, similar to numeric indices less than 1. In addition, gaps in between the indices lead to halts. The ordering is deterministic, by numeric magnitude.

pairs() returns key-value pairs and is mostly used for associative tables. All keys are preserved, but the order is unspecified

--------------------

x:bar(3,4)should be the same as x.bar(x,3,4).

local x = {
    foo = function(a, b) return a end,
    bar = function(a,b) return b end
}

return x.foo(3, 4) -- 3
return x.bar(3, 4) -- 4
return x:foo(3, 4) -- table: 0x10a120
return x:bar(3, 4) -- 3














Herencia de clases:
https://stackoverflow.com/questions/65961478/how-to-mimic-simple-inheritance-with-base-and-child-class-constructors-in-lua-t



]]