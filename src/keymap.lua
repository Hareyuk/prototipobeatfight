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
 	return self
end

--Tiempo en ms entre ahora y cuando se presionó por ultima vez
function Tecla:dt_last_press()
	local dtiempo = love.timer.getTime() - self.last_pressed_time  --tiempo en segundos
	return dtiempo*1000 --tiempo en ms
end

Teclas = {}

----------------------------------------------------------------------------------------------------
--Acá se definen los mapeos de keys para los controles.

--Basicamente la idea es que iternamente hay un "Comando de derecha", "Comando de izquierda", "Comando de ataque,
-- y que mapeamos cada tecla del input a uno de estos comandos

mapaTeclas_multiplayer = {
	right =	'Pje1_right', --tecla derecha
	left  =	'Pje1_left',  --tecla izquierda
	up    =	'Pje1_up',
	down  = 'Pje1_down', 
   z = 'Pje1_atk1'
}

--La hago bidireccional, asi puedo hacer que los objetos chequeen si algo está presionado tambien 
for key, value in pairs(mapaTeclas_multiplayer) do
	mapaTeclas_multiplayer[value] = key
	Teclas[key] = Tecla:new(key)
	Teclas[value] = Teclas[key] --Mayor comodidad de poder referirse a la tecla segun la tecla real y el comando que se ejecutó
end


--Descartar por ahi
mapaTeclas_singleplayer = {
	right = 'Pje2_right', --tecla derecha
	left  = 'Pje2_left'  --tecla izquierda
}


---------------------------------------------------------------------------------

--This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. 
function love.keypressed(key)

   comando = mapaTeclas_multiplayer[key]

   local tecla = Teclas[key]

   tecla.isDown = true

   --Aca hubo complicacion al pepe... se podria haber hecho un diccionario "Comandos" y que sea Comandos[tecla]:enviar()
   if      comando == 'Pje1_right' then
      pje1:comandoRightPress()
   elseif comando == 'Pje1_left'  then
      pje1:comandoLeftPress()
   elseif comando == 'Pje1_up'  then
      pje1:comandoUpPress()
   elseif comando == 'Pje1_down'  then
      pje1:comandoDownPress()
   elseif comando == 'Pje1_atk1' then
      pje1:comandoAtk1Press()

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

   Teclas[key].isDown = false
   comando = mapaTeclas_multiplayer[key]

   if      comando == 'Pje1_right' then
      pje1:comandoRightRelease()
   elseif comando == 'Pje1_left'  then
      pje1:comandoLeftRelease()
   elseif comando == 'Pje1_up'  then
      pje1:comandoUpRelease()
   elseif comando == 'Pje1_down'  then
      pje1:comandoDownRelease()
   end

end  

