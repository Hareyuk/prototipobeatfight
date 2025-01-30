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
	return dtiempo --tiempo en s
end


----------------------------------------------------------------------------------------------------
--Acá se definen los mapeos de keys para los controles.

--Basicamente la idea es que iternamente hay un "Comando de derecha", "Comando de izquierda", "Comando de ataque,
-- y que mapeamos cada tecla del input a uno de estos comandos

--Primero me hago una unica tabla que tenga todas las teclas que reconozco, y a que jugador le pertenecen

--Todo: No hay escape a lo del prefijo sin sobrecomplicarla. Volver a lo anterior
Keybindings = {}


--Es un diccionario de comandoName --> Tecla (ej 'saltar' --> Teclas['spacebar'])
mapaTeclas_P1 = {

   --Personaje 1
   right =  'p_right', --tecla derecha
   left  =  'p_left',  --tecla izquierda
   up    =  'p_up',
   down  = 'p_down', 
   z = 'atk1',
   ['1'] = 'grow',
   ['2'] = 'shrink'
}


--Personaje 2
mapaTeclas_P2 = {
   d =  'p_right', --tecla derecha
   a  =  'p_left',  --tecla izquierda
   w    =  'p_up',
   s  = 'p_down', 
   f = 'atk1',
   x = 'grow',
   c = 'shrink'
}

--Ahora, creo un objeto Tecla por cada tecla, y le asigno al mapa de cada jugador lo que le corresponde

Teclas = {}
--La motivacion es que esto me permite luego hacer Personaje.teclas['saltar'] --> devuelve la Tecla para ese comando
for key, command in pairs(mapaTeclas_P1) do

   Teclas[key] = Tecla:new(key)

   mapaTeclas_P1[command] = Teclas[key] 

   print(key, command)

end

for key, command in pairs(mapaTeclas_P2) do
   Teclas[key] = Tecla:new(key)
   mapaTeclas_P2[command] = Teclas[key]
end


--Asigno keybidings de teclas (comandos) a funciones de personaje.
comandos = {}

comandos['p_right'] = Personaje.comandoRightPress
comandos['p_left'] = Personaje.comandoLeftPress
comandos['p_up'] = Personaje.comandoUpPress
comandos['p_down'] = Personaje.comandoDownPress
comandos['atk1'] = Personaje.comandoAtk1Press
comandos['grow'] = nil
comandos['shrink'] = nil


--Para cuando se suelta la tecla. Ocasional, solo para las teclas de movimiento creo, los otros no usan
comandos_release = {}
comandos_release['p_right'] = Personaje.comandoRightRelease
comandos_release['p_left'] = Personaje.comandoLeftRelease
comandos_release['p_up'] = Personaje.comandoUpRelease
comandos_release['p_down'] = Personaje.comandoDownRelease
comandos_release['atk1'] = nada



Teclas['q'] = Tecla:new('q')
---------------------------------------------------------------------------------

--This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. 
function love.keypressed(key)


   local tecla = Teclas[key]
   if not tecla then return end -- Si no es una tecla que me interese, salgo

   tecla.isDown = true

   --Si es un comando de J1, lo ejecuto   
   if esClave(key, mapaTeclas_P1)  then  --tecla.name es == key
      print('Soy ' .. key)
      comando = mapaTeclas_P1[key]
      comandos[comando](pje1, tecla) --Hago que el pje ejecute este comando
   end

   --Si es un comando de J2, lo ejecuto   
   if esClave(key, mapaTeclas_P2)  then  --tecla.name es == key
      print('Soy ' .. key)
      comando = mapaTeclas_P2[key]
      comandos[comando](pje2, tecla)
   end

   if key == 'return' then avanzarTexto()


   elseif key == 'space' then fondo:cambiarFondo()

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



   --Todo repensar seriamente todo esto que me está trayendo varios problemas
   --Si es un comando de J1, lo ejecuto   
   if esClave(key, mapaTeclas_P1)  then 
      comando = mapaTeclas_P1[key]
      comandos_release[comando](pje1, tecla)
   end


   --Si es un comando de J2, lo ejecuto   
   if esClave(key, mapaTeclas_P2)  then 
      comando = mapaTeclas_P2[key]
      comandos_release[comando](pje2, tecla)
   end
end  

