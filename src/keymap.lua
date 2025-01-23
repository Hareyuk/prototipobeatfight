------------------------------------ Aca se define la estructura de Teclas
-- Algunas teclas necesitan registrar cuanto tiempo pasó desde el ultimo toque

Tecla = {
		name = '', --nombre de la tecla
		last_pressed_time = 0, --momento en que se presionó por última vez
      last_prev_pressed_time = -9999, --momento en que se presiono por anteultima vez. para el dash
		isDown = false
      }

Tecla.__index = Tecla --Crea clase

--Constructor de objeto
function Tecla:new(name)
	local self = setmetatable({}, Tecla)
    self.name = name or ''
    self.padre = nil -- instancia de Personaje. Cuando se apriete una tecla, se va a llamar a una funcion del personaje
 	return self
end

--Tiempo en ms entre ahora y cuando se presionó por ultima vez
function Tecla:dt_last_press()
	local dtiempo = love.timer.getTime() - self.last_pressed_time  --tiempo en segundos
	return dtiempo*1000 --tiempo en ms
end


----------------------------------------------------------------------------------------------------
--Acá se definen los mapeos de keys para los controles.

--Basicamente la idea es que iternamente hay un "Comando de derecha", "Comando de izquierda", "Comando de ataque,
-- y que mapeamos cada tecla del input a uno de estos comandos

--Primero me hago una unica tabla que tenga todas las teclas que reconozco, y a que jugador le pertenecen
Keybindings = {

   --Personaje 1
   right =  {'right', 1}, --tecla derecha
   left  =  {'left', 1},  --tecla izquierda
   up    =  {'up', 1},
   down  = {'down', 1}, 
   z = {'atk1', 1},
   ['1'] = {'grow', 1},
   ['2'] = {'shrink', 1},

   --Personaje 2
   d =  {'right', 2}, --tecla derecha
   a  =  {'left', 2},  --tecla izquierda
   w    =  {'up', 2},
   s  = {'down', 2}, 
   f = {'atk1', 2},
   x = {'grow', 2},
   c = {'shrink', 2}
}



mapaTeclas_P1 = {}
mapaTeclas_P2 = {}

--Ahora, creo un objeto Tecla por cada tecla, y le asigno al mapa de cada jugador lo que le corresponde
--Esto lo podria haber hecho directamente al definir mapa_p1 y mapa_p2, PERO estaba muy keen en tener 'right' como nombre de comando.
--Asi que esta fue la solucion mas "tranqui"
--El MALABAR GIGANTE que hubo que hacer por ese capricho no tiene nombre.... alcanzaba con renombrar el comando "right" a "p_right"... pero bueno...

Teclas = {}
--La motivacion es que esto me permite luego hacer Personaje.teclas['saltar'] --> devuelve la Tecla para ese comando
for key, command in pairs(Keybindings) do

   Teclas[key] = Tecla:new(key)

   if command[2] == 1 then mapaTeclas_P1[command[1]] = Teclas[key] end
   if command[2] == 2 then mapaTeclas_P2[command[1]] = Teclas[key] end
end



--Asigno keybidings de teclas (comandos) a funciones de personaje.
comandos = {}

comandos['right'] = Personaje.comandoRightPress
comandos['left'] = Personaje.comandoLeftPress
comandos['up'] = Personaje.comandoUpPress
comandos['down'] = Personaje.comandoDownPress
comandos['atk1'] = nil
comandos['grow'] = nil
comandos['shrink'] = nil


--Para cuando se suelta la tecla. Ocasional, solo para movimiento creo
comandos_release = {}
comandos_release['right'] = Personaje.comandoRightRelease
comandos_release['left'] = Personaje.comandoLeftRelease
comandos_release['up'] = Personaje.comandoUpRelease
comandos_release['down'] = Personaje.comandoDownRelease
comandos_release['atk1'] = nil

---------------------------------------------------------------------------------

--This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. 
function love.keypressed(key)


   local tecla = Teclas[key]
   if not tecla then return end -- Si no es una tecla que me interese, salgo

   tecla.isDown = true

   --Si es un comando de J1, lo ejecuto   
   if esClave(key,mapaTeclas_P1)  then --tecla.name es == key
      comandos[key](pje1, tecla)
   end


   if key == 'return' then avanzarTexto()


   elseif key == 'space' then fondo:cambiarFondo()

   elseif key == 'escape' then love.quit()
   end

	--registro cuando se pulsó esta tecla
   --Esto va ultimo porque primero tengo que poder chequear contra el tiempo anterior
   tecla.last_pressed_time = love.timer.getTime() 

end



function love.keyreleased(key)

   local tecla = Teclas[key]
   if not tecla then return end -- Si no es una tecla que me interese, salgo


   tecla.isDown = false

   --Si es un comando de J1, lo ejecuto   
   if esClave(key,mapaTeclas_P1)  then 
      comandos_release[key](pje1, tecla)
   end


end  

