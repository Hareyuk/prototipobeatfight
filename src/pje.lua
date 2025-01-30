--El personaje es una especializacion de "Objeto"
require "objeto" 

--[[ 
      Estados:

      -Idle
      -Caminando
      -Corriendo
      -Ataque basico
      -Ataque fuerte
      -Defensa
      -Dash
      -Siendo golpeado
]]

Estados_Pje ={
   IDLE = 1,
   WALK = 2,
   DASH = 3,
   RUN  = 3.5,
   ATK1 = 4,
   ATK2 = 5,
   INTERACT = 6,
   HURT1 = 7,
   HURT2 = 8,
   SHIELD = 9,
   RECOVER = 10
}

--Creo la clase Personaje como Hija de Objeto. Las cosas nuevas las agrego abajo, en el "constructor" (el nombre "new" es generico, no necesario)
--Personaje = Objeto:new()
Personaje = setmetatable({}, Objeto)
Personaje.__index = Personaje


--[[
   Agrega los atributos (detallar)

]]

--CONSTANTES DE VELOCIDAD Y MOVIMIENTO
dt_RUN = 400 --ms. Tiempo maximo permitido entre dos aprietes de tecla consecutivos para empezar a correr
dt_DASH = 150 --ms. Tiempo maximo permitido para soltar la tecla desde la ultima apretada para ver si corre o dashea
dash_timer_max = 300/1000 --s  tiempo que dura el dasheo


--Constructor
function Personaje:new(id)
   print("Creando personaje: " .. id)

   local self = Objeto:new('Personaje '.. id)
   setmetatable(self, {__index = Personaje}) --Crea una instancia de objeto
   self.__index = self

   --SPRITES VIEJOS
   --[[
   self:addEstado('IDLE', "pje/reposo/", Personaje.init_idle)
   self:addEstado('WALK', "pje/caminando/", nil, Personaje.update_walk)
   self:addEstado('RUNX',  "pje/caminando/")
   self:addEstado('RUNY',  "pje/caminando/")

   self:addEstado('DASH',  "pje/dash/", Personaje.initDash, Personaje.updateDash)
   self:addEstado('ATK1', "pje/boxtest/")
]]
   
   --SPRITES
   self:addEstado('IDLE', "knight/idle-h/", Personaje.init_idle, nil, 'Derecha')
   self:addOrientacionEstado('IDLE', "knight/idle-up/",  'Arriba')
   self:addOrientacionEstado('IDLE', "knight/idle-down/",'Abajo')
   self:addOrientacionEstado('IDLE', "knight/idle-h/",  'Izquierda')  --Todo: Pensar si dejar asi o si se resuelve de otra manera


   self:addEstado('WALK', "knight/walk-h/", nil, Personaje.update_walk, 'Derecha')
   self:addOrientacionEstado('WALK', "knight/walk-up/", 'Arriba')
   self:addOrientacionEstado('WALK', "knight/walk-down/",'Abajo')
   self:addOrientacionEstado('WALK', "knight/walk-h/",'Izquierda')

   --Todo ver si cambiar nombre de esta fun a update_mvt
   self:addEstado('RUN', "knight/run-h/", nil, Personaje.update_run, 'Derecha')
   self:addOrientacionEstado('RUN', "knight/run-up/", 'Arriba')
   self:addOrientacionEstado('RUN', "knight/run-down/",'Abajo')
   self:addOrientacionEstado('RUN', "knight/run-h/",'Izquierda')

   --self:addEstado('DASH',  "pje/dash/", Personaje.initDash, Personaje.updateDash)
   --self:addEstado('ATK1', "pje/boxtest/")
   

   --DIMENSIONES REALES 
   self.true_x =

   --Estado actual
   self:setEstado('IDLE')   
   self.orientacion = 'Derecha'


   self:setScale(0.6)
   self.rate = 5 -- rate de ciclado de sprites


   --DEBUG:
   for i, estado in pairs(self.estados) do
      print('Estados de ' .. self.name .. ' : '..  estado.name)
   end

   --Agrego colisiones con código
   self:addCollisionBoxPies()


   --POSICION
   self.x = SCREEN_WIDTH
   self.y = SCREEN_HEIGHT*1.4 / id



   --MAPA DE TECLAS
   if(id == 1) then self.teclas = mapaTeclas_P1 end
   if(id == 2) then self.teclas = mapaTeclas_P2 end


   --Constantes de velocidad
   self.vwalk_x = 180 -- Velocidad de caminar
   self.vwalk_y = 120 --Velocidad de caminar en y
   self.vrun_x = 400 -- Velocidad de correr
   self.vrun_y = 300 -- Velocidad de correr

   self.vdash = 5500

--[[
   --AJUSTO LOS SPRITES (Trim bordes vacios, ajustandolos todos al estado "idle")
   local x,y,w,h = getXYWH(self.estados['IDLE'].frames.imagen)
   local idleimgdata = love.image.newImageData('img/knight/idle-h')
   trimSprites(self, x,y,w,h)
   ]]

   print("Personaje creado!")
   
   return self
end

--Para dibujar al Knight, tomo las coordenadas (x,y)  centrales del frame. 
--Todo: Por ahora NADA distinto al frame de objeto. Puede volar
function Personaje:drawFrame()

   local sp = self:getFrameActual().imagen --sprite a dibujar, es una imagen

   --local x,y = self.x + self.w/2, self.y + self.h/2
   local x,y = self.x, self.y

   if self.orientacion == 'Izquierda' then
      drawImage2Izq(sp, x, y, self.scale)

   else 
      drawImage2(sp, x, y, self.scale)
   end

   if(DEBUG) then
      self:mostrarCoords()
      self:mostrarBordes()
      self:mostrarCentro()



      self:mostrarHurtbox()
      self:mostrarCollisionbox()
      self:mostrarHitbox()
   end

end


--Agrego colisiones en los pies
--Todo ver por qué pinga self.estados es siempre tabla vacía
function Personaje:addCollisionBoxPies()

   local pie_x, pie_w = self.w*0.6, self.w*0.4
   local pie_y, pie_h = self.h*0.95, self.h*0.3

   print('Creando colisionboxes en pies de ' .. self.name)

   -- print('\n\n\n\n' .. ' ' .. pie_x .. ' ' .. ' '.. pie_y .. ' ' ..  pie_w ..' '.. pie_h)
  -- print(h)
  -- print(self:getFrameActual().imagen:getWidth())
   for i, estado in pairs(self.estados) do
      print('Creando colisiones en estado ' .. estado.name)
      for j, frame in pairs(estado.frames) do
         print(frame.name)
         for k, frame_orientacion in pairs(frame) do
            print(frame_orientacion)
            frame_orientacion.collisionbox = Box:new(pie_x, pie_y, pie_w,  pie_h)
         end
      end
   end

   return
end


--TODO todos los chequeos de teclas tienen que indexarse de otra manera

function Personaje:update(dt)

   --Posicion, frame actual y acciones de estado
   Objeto.update(self, dt)  --OJO: La sintaxis del ":" reemplazando al "self" como 1er parametro no funciona acá, por alguna razon


   --Se fija como actualizar las vars de movimiento
   --Al salir de algunos estados, sí tendria que chequear esto creo
   --self:chequearTeclas(dt) 
   --self:actualizarEstado(dt)

   --Limites de la pantalla
   --self.x = math.clamp(self.x,0, SCREEN_WIDTH - self.currentFrame:getWidth()*self.scale) --Se le podría agregar un "acell = 0 y vel=0" en los casos que choca, si fuera más pro
   --self.y = math.clamp(self.y,0, SCREEN_HEIGHT)

   --if self.teclas['grow'].isDown then self.scale = self.scale + 2*dt end
   --if self.teclas['shrink'].isDown then self.scale = self.scale - 2*dt end



   --[[
   --Veo si Estoy IDLE: Ninguna tecla pulsada y vengo de un estado de movimieneto
   if self:estaEnEstado({'WALK', 'RUN'}) and not
      (Teclas['Pje1_right'].isDown or Teclas['Pje1_left'].isDown or Teclas['Pje1_up'].isDown or Teclas['Pje1_down'].isDown)
   then
      self:setEstado('IDLE')
      self.velx, self.vely = 0 , 0 
   end
   
   --Veo si estoy IDLE: si mi vel es 0
   if self:estaEnEstado({'WALK', 'RUNX', 'RUNY'}) and 
      self.velx == 0 and self.vely == 0
   then
      self:setEstado('IDLE')
      self.velx, self.vely = 0 , 0 
   end
]]



   --CAMARA: El personaje no puede salirse de los límites de la cámara

   if self.isCamLocked and camera.mode == 'center' then
      self.x = math.clamp(self.x, camera.x, camera.x + camera:getWidth() - self.w/2)
      self.y = math.clamp(self.y, camera.y, camera.y + camera:getHeight() - self.h/2)
   end

end   

--Todo: Que todos los self.scale sean siempre 1 y listo... paz.... 


------------------------------  COMANDOS MOVIMIENTO ---------------------------------------------



------------------------------  PRESS

--Idea: Para el mvt: Cada ciclo, setear v = 0, y sumar en direccion por cada boton pulsado.
--Luego normalizar el vector a la speed del personaje

--Estas cuatro fun de flechitas se pueden resumir en una sola fun

--Recibe un "mover a la derecha"
--Tecla id: 'Pje1_right'
function Personaje:comandoRightPress(tecla)

   print('Hola!! Soy ' .. self.name)

   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
      self.orientacion = 'Derecha'
   end

   --Veo si puedo empezar un RUN
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
   end

  --print(Teclas['Pje1_right']:calcular_dt(), Teclas['Pje1_right'].last_pressed_time)

end

--Recibe un "mover a la izquierda"
function Personaje:comandoLeftPress(tecla)

   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
      self.orientacion = 'Izquierda'
   end

   --Veo si puedo empezar un RUN
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
   end
end


--Recibe un "mover arriba"
function Personaje:comandoUpPress(tecla)

   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
      self.orientacion = 'Arriba'
   end

   --Veo si puedo empezar un RUN
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
   end

end

function Personaje:comandoDownPress(tecla)
      
   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
      self.orientacion = 'Abajo'
   end

   --Veo si puedo empezar un RUN
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
   end
end


------------------------------  RELEASE



--Recibe un "ya no se mueve a la derecha"
function Personaje:comandoRightRelease(tecla)
   

   --Veo si puedo empezar un Dash
   dt_release = tecla:dt_last_press()
   if self:estaEnEstado({'RUN'}) and dt_release < dt_DASH then
         self:setEstado('DASH')
         return
   end

   if self:estaEnEstado({'IDLE', 'WALK'}) then self:recalcularOrientacion() end

end

--Recibe un "ya no se mueve a la izquierda"
function Personaje:comandoLeftRelease()


   if self:estaEnEstado({'IDLE', 'WALK'}) then self:recalcularOrientacion() end

end



--Recibe un "ya no se mueve arriba"
function Personaje:comandoUpRelease()

   if self:estaEnEstado({'IDLE', 'WALK'}) then self:recalcularOrientacion() end

end

--Recibe un "ya no se mueve abajo"
function Personaje:comandoDownRelease()


   if self:estaEnEstado({'IDLE', 'WALK'}) then self:recalcularOrientacion() end

end


function Personaje:comandoAtk1Press()
   self:setEstado('ATK1')
   self.scale = 0.3
end


function Personaje:keypressed(key)
   if key == 'right' then self.velx = self.velx + self.v0
      self.orientacionX = Orientaciones.DERECHA

   elseif key == 'left' then self.velx = self.velx - self.v0
      self.orientacionX = Orientaciones.IZQUIERDA 
   end
end


--------------------      DASH      ------------------------

--Se llama cuando se entra al dash. Podría ser parte de una funcion de estado tambien en vez de personaje
--O sea, esta logica se puede rehacer, para no llamar a esta funcion en las teclas sino solo a setearEstado

function Personaje:initDash()
   self.dash_timer = 0
   --self.scale = 1
   return
end

--Acá se actualiza el  dasheo
-- La idea es que hay un timer y que la velocidad y cuando termina el dash dependen de este timer 
-- tambien se controla la animacion desde acá
function Personaje:updateDash(dt)


   --Si el dash terminó: vuelvo a Idle
   if self.dash_timer >= dash_timer_max then
      self:setEstado('IDLE')
      --self.scale = 3
      return
   end

   self.velx = self:dash_vt()
   self.dash_timer = self.dash_timer + dt

end 

--v(t) para el dash
--t en ms
function Personaje:dash_vt()

   local t = self.dash_timer

   local semicirculo = self.vdash*math.sqrt(-t*(t-dash_timer_max))
   local exponencial_dec = self.vdash*(10^(-t))
   local recta_dec = self.vdash*(dash_timer_max - t)
   return  recta_dec
end



--Esto es para llamar cuando solté alguna tecla de movimiento o algo así.
--Me fijo hacia donde miro según hacia donde me estoy moviendo

function Personaje:recalcularOrientacion()

   --Todo:s optimizable a costa de menos legibilidadx
   if self.velx == 0 and self.vely < 0 then self.orientacion = 'Arriba'
   elseif self.velx == 0 and self.vely > 0 then self.orientacion = 'Abajo'
   elseif self.vely == 0 and self.velx > 0 then self.orientacion = 'Derecha'
   elseif self.vely == 0 and self.velx < 0 then self.orientacion = 'Izquierda'

   end
end

--------------------      IDLE   & WALK   ------------------------


--Idea: Si hay fuerzas de arrastre o otro tipo, que la velocidad se componga de una "fuerza de mvt" propia (las teclas)
-- y otra "externa". Y vos solo seteas duro la propia y las externas van con aceleracion.
function Personaje:init_idle()
   self.velx, self.vely = 0,0
end


----  USADO EN IDLE y EN WALK --

--Asigno velocidad y sprites cuando camino y corro según las teclas que estén pulsadas
--Esto resume las tres funciones de "movimiento logica 1.txt" de demo.
-- Los llaman una fun de walk, una de runx, y otra de runy
--Todo falta asignas sprites
--Nota: Esto es mucho más caro que recalcular cuando me llega un press, porque se hace todos los frames
function Personaje:chequearVelocidadDeMovimiento(vx, vy)

   self.velx = 0
   self.vely = 0

   if self.teclas['p_right'].isDown then self.velx = self.velx + vx end
   if self.teclas['p_left'].isDown then self.velx = self.velx - vx end
   if self.teclas['p_up'].isDown then self.vely = self.vely - vy end
   if self.teclas['p_down'].isDown then self.vely = self.vely + vy end

   --if not( Teclas['Pje1_down'].isDown or Teclas['Pje1_up'].isDown or Teclas['Pje1_right'].isDown or Teclas['Pje1_left'].isDown) 
     -- then self:setEstado('IDLE')
   --end

   if(self.velx == 0 and self.vely == 0) then self:setEstado('IDLE') 
   else self:recalcularOrientacion() end --todo: optimizable, esto se puede chequear solo cuando se suelta una tecla guardando un bool para que se chequee en el siguiente update del pje (llamando a la funcion desde el keyreleased no va a andar)


   --Todo normalizar segun walk o run vector velocidad
   return

end

--Funcion en desuso
function Personaje:update_idle(dt)
   self:chequearVelocidadDeMovimiento(self.vwalk_x, self.vrun_y)
end

--Si estoy caminando, asigno la velocidad según las teclas presionadas
function Personaje:update_walk(dt)
   self:chequearVelocidadDeMovimiento(self.vwalk_x, self.vwalk_y)
end

function Personaje:update_run(dt)
   if(estaEn({'Derecha', 'Izquierda'}, self.orientacion)) then
      self:chequearTeclasMovimientoRunX(dt)
   elseif (estaEn({'Arriba', 'Abajo'}, self.orientacion)) then
      self:chequearTeclasMovimientoRunY(dt)
   end
end

--Asigno velocidad y sprites cuando corro horizontal
function Personaje:chequearTeclasMovimientoRunX(dt)
   self:chequearVelocidadDeMovimiento(self.vrun_x, self.vwalk_y)
 end

--Asigno velocidad y sprites cuando corro vertical
function Personaje:chequearTeclasMovimientoRunY(dt)
   self:chequearVelocidadDeMovimiento(self.vwalk_x, self.vrun_y)
end

--Otra idea para la logica del movimiento, para pensar:
--Cuando presiono -->, pongo tecla_izq.isDown = false. 
--Cuando suelto -->, chequeo con love y seteo tecla_izq acordemente. 
