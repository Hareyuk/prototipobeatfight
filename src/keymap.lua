------------------------------------ Aca se define la estructura de Teclas
-- Algunas teclas necesitan registrar cuanto tiempo pasó desde el ultimo toque

Tecla = {
		name = '', --nombre de la tecla
		last_pressed_time = 0, --momento en que se presionó por última vez
		isDown = false
      }

Tecla.__index = Tecla --Crea clase

--Constructor de objeto
function Tecla:new(name)
	local self = setmetatable({}, Tecla)
    self.name = name or ''
 	return self
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
	down  = 'Pje2_down'
}

--La hago bidireccional, asi puedo hacer que los objetos chequeen si algo está presionado tambien 
for key, value in pairs(mapaTeclas_multiplayer) do
	mapaTeclas_multiplayer[value] = key
end

for key, value in pairs(mapaTeclas_multiplayer) do
	Teclas[key] = Tecla:new(key)
end

--Descartar por ahi
mapaTeclas_singleplayer = {
	right = 'Pje2_right', --tecla derecha
	left  = 'Pje2_left'  --tecla izquierda
}


---------------------------------------------------------------------------------


function love.keypressed(key)

   comando = mapaTeclas_multiplayer[key]

   Teclas[key].isDown = true
   Teclas[key].last_pressed_time = love.timer.getTime() --registro que ahora se pulsó esta tecla

   if      comando == 'Pje1_right' then
      pje1:comandoRightPress()
   elseif comando == 'Pje1_left'  then
      pje1:comandoLeftPress()
   elseif comando == 'Pje1_up'  then
      pje1:comandoUpPress()
   elseif comando == 'Pje1_down'  then
      pje1:comandoDownPress()
   end

   if key == 'return' then avanzarTexto()


   elseif key == 'space' then fondo:cambiarFondo()

   elseif key == 'escape' then love.quit()
   end


end
--This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. 

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

