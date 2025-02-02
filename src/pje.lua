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
dt_RUN = 400/1000 --ms. Tiempo maximo permitido entre dos aprietes de tecla consecutivos para empezar a correr
dt_DASH = 150/1000 --ms. Tiempo maximo permitido para soltar la tecla desde la ultima apretada para ver si corre o dashea
dash_timer_max = 300/1000 --ms  tiempo que dura el dasheo

atk1_timer_max = 500/1000 --ms, tiempo que tengo para encadenar el ataque1
hurt1_timer_max = 300/1000 --Tiempo que dura el daño1

Pjes = {} -- Lista de personajes

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
   self:addOrientacionEstado('IDLE', "knight/idle-h/",  'Izquierda')  
   --Todo: Pensar si resolver de otra manera las orientaciones izq (no repetir sprites en memoria)

   self:addEstado('WALK', "knight/walk-h/", nil, Personaje.update_walk, 'Derecha')
   self:addOrientacionEstado('WALK', "knight/walk-up/", 'Arriba')
   self:addOrientacionEstado('WALK', "knight/walk-down/",'Abajo')
   self:addOrientacionEstado('WALK', "knight/walk-h/",'Izquierda')

   --Todo ver si cambiar nombre de esta fun a update_mvt
   self:addEstado('RUN', "knight/run-h/", nil, Personaje.update_run, 'Derecha')
   self:addOrientacionEstado('RUN', "knight/run-up/", 'Arriba')
   self:addOrientacionEstado('RUN', "knight/run-down/",'Abajo')
   self:addOrientacionEstado('RUN', "knight/run-h/",'Izquierda')

   self:addEstado('DASH', "knight/dash-h/", Personaje.initDash, Personaje.updateDash, 'Derecha')
   self:addOrientacionEstado('DASH', "knight/dash-up/", 'Arriba')
   self:addOrientacionEstado('DASH', "knight/dash-down/",'Abajo')
   self:addOrientacionEstado('DASH', "knight/dash-h/",'Izquierda')

   self:addEstado('ATK11', "knight/atk11-h/", Personaje.initAtk11, Personaje.updateAtk1, 'Derecha')
   self:addOrientacionEstado('ATK11', "knight/atk11-up/", 'Arriba')
   self:addOrientacionEstado('ATK11', "knight/atk11-down/",'Abajo')
   self:addOrientacionEstado('ATK11', "knight/atk11-h/",'Izquierda')

   self:addEstado('ATK12', "knight/atk12-h/", Personaje.initAtk12, Personaje.updateAtk1, 'Derecha')
   self:addOrientacionEstado('ATK12', "knight/atk12-up/", 'Arriba')
   self:addOrientacionEstado('ATK12', "knight/atk12-down/",'Abajo')
   self:addOrientacionEstado('ATK12', "knight/atk12-h/",'Izquierda')


   self:addEstado('ATK13', "knight/atk13-h/", Personaje.initAtk13, Personaje.updateAtk1, 'Derecha')
   self:addOrientacionEstado('ATK13', "knight/atk13-up/", 'Arriba')
   self:addOrientacionEstado('ATK13', "knight/atk13-down/",'Abajo')
   self:addOrientacionEstado('ATK13', "knight/atk13-h/",'Izquierda')

   self:addEstado('HURT1', "knight/hurt1-h/", Personaje.initHurt1, Personaje.updateHurt1, 'Derecha')
   self:addOrientacionEstado('HURT1', "knight/hurt1-up/", 'Arriba')
   self:addOrientacionEstado('HURT1', "knight/hurt1-down/",'Abajo')
   self:addOrientacionEstado('HURT1', "knight/hurt1-h/",'Izquierda')


   

   --self:addEstado('ATK1', "pje/boxtest/")


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
   self:addHurtBoxCuerpo()
   self:addDurationFrames()

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

   Pjes[id] = self --Agrego a la lista global de personajes
   
   return self
end

--Para dibujar al Knight, tomo las coordenadas (x,y)  centrales del frame. 
--Todo: Por ahora NADA distinto al frame de objeto. Puede volar

function Personaje:drawFrame()

   local sp = self:getFrameActual().imagen --sprite a dibujar, es una imagen

   --local x,y = self.x + self.w/2, self.y + self.h/2
   local x,y = self.x, self.y

   --Todo cambiar acá que se use el frame para OrDerecha. Asi no hay que guardar duplicados 
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
         for k, frame_orientacion in pairs(frame) do
            frame_orientacion.collisionbox = Box:new(pie_x, pie_y, pie_w,  pie_h)
         end
      end
   end

   return
end

function Personaje:addHurtBoxCuerpo()

   local cuerpo_x, cuerpo_w = self.w*0.6, self.w*0.4
   local cuerpo_y, cuerpo_h = self.h*0.7, self.h*0.4

   print('Creando Hurtboxes en cuerpo de ' .. self.name)

   for ename, estado in pairs(self.estados) do
      print('Creando Hurtboxes en estado ' .. estado.name)
      for oname, orientacion in pairs(estado.frames) do
         for k, frame in pairs(orientacion) do
            frame.hurtbox = Box:new(cuerpo_x, cuerpo_y, cuerpo_w,  cuerpo_h)
         end
      end
   end

   return
end

--Setea la duracion de algunos frames claves, que duran más
function Personaje:addDurationFrames()


   --Seteo al doble la duracion del primero de todos los frames de ataque
   for ename, estado in pairs(self.estados) do
      if estaEn({'ATK11', 'ATK12', 'ATK13'}, estado.name) then
         print('Alargando durs en estado ' .. estado.name)
         for oname, orientacion in pairs(estado.frames) do
            print('Alargando dur en orientacion '.. oname)
            estado.frames[oname][1].dur = 1.5
         end

      end
   end
end   

--Todo
--Copia los frames de un estado a otro
--En realidad, no se copia sino que se hace una referenca
function Personaje:copiarFrames(estado_from, estado_to)
end



--TODO todos los chequeos de teclas tienen que indexarse de otra manera

function Personaje:update(dt)

   --Posicion, frame actual y acciones de estado
   Objeto.update(self, dt)  --OJO: La sintaxis del ":" reemplazando al "self" como 1er parametro no funciona acá, por alguna razon


   --Se fija como actualizar las vars de movimiento
   --Al salir de algunos estados, sí tendria que chequear esto creo
   --self:chequearTeclas(dt) 
   --self:actualizarEstado(dt)


   --if self.teclas['grow'].isDown then self.scale = self.scale + 2*dt end
   --if self.teclas['shrink'].isDown then self.scale = self.scale - 2*dt end


   --CAMARA: El personaje no puede salirse de los límites de la cámara

   --Limites de la pantalla
   --self.x = math.clamp(self.x,0, SCREEN_WIDTH - self.currentFrame:getWidth()*self.scale) --Se le podría agregar un "acell = 0 y vel=0" en los casos que choca, si fuera más pro
   --self.y = math.clamp(self.y,0, SCREEN_HEIGHT)

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

--Funcion global para que las cuatro teclas llamen. Total siempre hago lo mismo
function Personaje:comandoMovtPress(tecla, orientacion)

   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
      self.orientacion = orientacion
   end

   --Veo si puedo empezar un RUN
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
   end

end


--Recibe un "mover a la derecha"
--Tecla id: 'Pje1_right'
function Personaje:comandoRightPress()

   self:comandoMovtPress(self.teclas['p_right'], 'Derecha')
end

--Recibe un "mover a la izquierda"
function Personaje:comandoLeftPress()

   self:comandoMovtPress(self.teclas['p_left'], 'Izquierda')
end


--Recibe un "mover arriba"
function Personaje:comandoUpPress(tecla)
   self:comandoMovtPress(self.teclas['p_up'], 'Arriba')
end

function Personaje:comandoDownPress(tecla)
   self:comandoMovtPress(self.teclas['p_down'], 'Abajo')
end


------------------------------  RELEASE

--Funcion global para que las cuatro teclas llamen. 
function Personaje:comandoMovtRelease(tecla, orientacion)

   --Veo si puedo empezar un Dash
   dt_release = tecla:dt_last_press()
   if self:estaEnEstado({'RUN'}) and dt_release < dt_DASH and self.orientacion == orientacion then
         self:setEstado('DASH')
         return
   end

   if self:estaEnEstado({'IDLE', 'WALK'}) then self:recalcularOrientacion() end

end

--Recibe un "ya no se mueve a la derecha"
function Personaje:comandoRightRelease()
   self:comandoMovtRelease(self.teclas['p_right'], 'Derecha')
end

--Recibe un "ya no se mueve a la izquierda"
function Personaje:comandoLeftRelease()
   self:comandoMovtRelease(self.teclas['p_left'], 'Izquierda')
end

--Recibe un "ya no se mueve arriba"
function Personaje:comandoUpRelease()
   self:comandoMovtRelease(self.teclas['p_up'], 'Arriba')
end

--Recibe un "ya no se mueve abajo"
function Personaje:comandoDownRelease()
   self:comandoMovtRelease(self.teclas['p_down'], 'Abajo')
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

   if(self.orientacion == 'Derecha' or 
      self.orientacion == 'Izquierda') then self.velx = self:dash_vt() --Provisorio, queda un step hacia atrás re cool
   elseif self.orientacion == 'Abajo' then self.vely = self:dash_vt()
   elseif self.orientacion == 'Arriba' then self.vely = -self:dash_vt()
   end
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
   self.accx, self.accy = 0,0
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



------------------------------------  ATK1 
function Personaje:comandoAtk1Press(tecla)
   if(self:estaEnEstado({'IDLE', 'WALK', 'RUN'})) then self:setEstado('ATK11'); return end

   if(self:estaEnEstado({'ATK11'}) and tecla:dt_last_press() < atk1_timer_max) then
      self:setEstado('ATK12')
      return
   end

   if(self:estaEnEstado({'ATK12'}) and tecla:dt_last_press() < atk1_timer_max) then
      self:setEstado('ATK13')
      return
   end

end

function Personaje:initAtk11()
   self.atk1_timer = 0
   self.atkKnockback = 50 --Ricochet que le imprime a otro si le pega
end

function Personaje:initAtk12() self.atk1_timer = 0 ; self.atkKnockback = 70 end

function Personaje:initAtk13() self.atk1_timer = 0 ; self.atkKnockback = 120 end

function Personaje:updateAtk1(dt)


   if(self.atk1_timer >= atk1_timer_max) then
      self:setEstado('IDLE')
      return
   end

   self.atk1_timer = self.atk1_timer + dt
   --todo: Ver si voy a las otras fases

end




------------------------------------  HURT1 

function Personaje:initHurt1()
   self.hurt1_timer = 0
end

function Personaje:updateHurt1(dt)


   if(self.hurt1_timer >= hurt1_timer_max) then
      self:setEstado('IDLE')
      return
   end


   self.hurt1_timer = self.hurt1_timer + dt


   --Los personajes al pelear se imprimen knockback.
   --Esto se hace seteando una velocidad en direccion del gole
   --Para ir frenando, se setea una aceleracion que va decreciento

   self.accx = self.accx*(1-self.hurt1_timer/hurt1_timer_max)
   self.accy = self.accy*(1-self.hurt1_timer/hurt1_timer_max)

end


--Se llama cuando otro objeto lo golpea
function Personaje:recibirHit(otroObjeto)
   self:setEstado('HURT1')
end