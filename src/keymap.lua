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
 	 self.isDown = false
    self.last_pressed_time = 0
   --TODO:REhacer el keymap con esta logica de padre de teclas
   --Todo pensar si puede tener un campo de "orientacion", para las teclas de movimiento
   return self
end

--Tiempo en ms entre ahora y cuando se presionó por ultima vez
function Tecla:dt_last_press()
	local dtiempo = love.timer.getTime() - self.last_pressed_time  --tiempo en segundos
	return dtiempo --tiempo en s
end


----------------------------------------------------------------------------------------------------
--Acá se definen los mapeos de keys para los controles.

--Basicamente la idea es que iternamente hay un "Comando de derecha", "Comando de izquierda", "Comando de ataque,
-- y que mapeamos cada tecla del input a uno de estos comandos

--Primero me hago una unica tabla que tenga todas las teclas que reconozco, y a que jugador le pertenecen

--Es un diccionario de comandoName --> Tecla (ej 'saltar' --> Teclas['spacebar'])
mapaTeclas_P1 = {

   --Personaje 1
   p_right = 'right', --tecla derecha
   p_left  =  'left',  --tecla izquierda
   p_up    =  'up',
   p_down  = 'down', 
   atk1 = 'z',
   atk2 = 'x',
   grow = '1',
   shrink = '2'
}


--Personaje 2
mapaTeclas_P2 = {
   p_right = 'd', --tecla derecha
   p_left  =  'a',  --tecla izquierda
   p_up    =  'w',
   p_down  = 's', 
   atk1 = 'f',
   atk2 = 'd',
   grow = '3',
   shrink = '4'
}


--Asigno keybindings de teclas (comandos) a funciones de personaje.
comandos = {}
comandos['p_right'] = Personaje.comandoRightPress
comandos['p_left'] = Personaje.comandoLeftPress
comandos['p_up'] = Personaje.comandoUpPress
comandos['p_down'] = Personaje.comandoDownPress
comandos['atk1'] = Personaje.comandoAtk1Press
comandos['atk2'] = Personaje.comandoAtk2Press
comandos['grow'] = nil
comandos['shrink'] = nil


--Para cuando se suelta la tecla. Ocasional, solo para las teclas de movimiento creo, los otros no usan
comandos_release = {}
comandos_release['p_right'] = Personaje.comandoRightRelease
comandos_release['p_left'] = Personaje.comandoLeftRelease
comandos_release['p_up'] = Personaje.comandoUpRelease
comandos_release['p_down'] = Personaje.comandoDownRelease
comandos_release['atk1'] = nada
comandos_release['atk2'] = Personaje.comandoAtk2Release


--Ahora, creo un objeto Tecla por cada tecla, y le asigno al mapa de cada jugador lo que le corresponde
Teclas = {}

--mapaComandos_Global['z'] --> (1, atk1)
mapaTeclas_Global = {}

for commandname, keyname in pairs(mapaTeclas_P1) do
   mapaTeclas_Global[keyname] = {1,commandname}
   Teclas[keyname] = Tecla:new(keyname)
   mapaTeclas_P1[commandname] = Teclas[keyname] --Piso el nombre de tecla por la tecla completa
end

for commandname, keyname in pairs(mapaTeclas_P2) do
   mapaTeclas_Global[keyname] = {2,commandname}
   Teclas[keyname] = Tecla:new(keyname)
   mapaTeclas_P2[commandname] = Teclas[keyname] --Piso lo anterior
end


---------------------------------------------------------------------------------

--This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. 
function love.keypressed(key)


   local tecla = Teclas[key]
   if not tecla then return end -- Si no es una tecla que me interese, salgo

   tecla.isDown = true

   --Si es un comando, lo ejecuto   
   if esClave(key, mapaTeclas_Global)  then  --tecla.name es == key
      local pjei, commandname = mapaTeclas_Global[key][1], mapaTeclas_Global[key][2] 
      print(pjei, commandname)
      comandos[commandname](Pjes[pjei]) --Hago que el pje ejecute este comando
   end



   if key == 'space' then fondo:cambiarFondo()

   elseif key == 'escape' then love.quit()

   elseif key == 'q' then print('Distancia p1 y p2: ' .. dist2(pje1, pje2)); print('Distancia L1 p1 y p2: ' .. dist1_scaled(pje1, pje2))

   end

	--registro cuando se pulsó esta tecla
   --Esto va ultimo porque primero tengo que poder chequear contra el tiempo anterior
   tecla.last_pressed_time = love.timer.getTime() 

end



function love.keyreleased(key)

   local tecla = Teclas[key]
   if not tecla then return end -- Si no es una tecla que me interese, salgo


   tecla.isDown = false

   if esClave(key, mapaTeclas_Global)  then  --tecla.name es == key
      print('Soy ' .. key)
      local pjei, commandname = mapaTeclas_Global[key][1], mapaTeclas_Global[key][2] 
      comandos_release[commandname](Pjes[pjei]) --Hago que el pje ejecute este comando
   end

end  
