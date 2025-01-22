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




ipairs() returns index-value pairs and is mostly used for numeric tables. The non-numeric keys are ignored as a whole, similar to numeric indices less than 1. In addition, gaps in between the indices lead to halts. The ordering is deterministic, by numeric magnitude.

pairs() returns key-value pairs and is mostly used for associative tables. All keys are preserved, but the order is unspecified

]]