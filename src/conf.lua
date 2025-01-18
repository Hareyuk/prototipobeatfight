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

]]