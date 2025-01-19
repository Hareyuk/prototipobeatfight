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
   RUN  = 4,
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
dt_DASH = 120 --ms. Tiempo maximo permitido para soltar la tecla desde la ultima apretada para ver si corre o dashea
dash_timer_max = 300/1000 --s  tiempo que dura el dasheo


--Constructor
function Personaje:new(id)
   print("Creando personaje: " .. id)

   local self = Objeto:new('Personaje '.. id)
   setmetatable(self, {__index = Personaje}) --Crea una instancia de objeto

   --SPRITES
   self:addEstado('IDLE', "pje/reposo/")
   self:addEstado('WALK', "pje/caminando/")
   self:addEstado('RUN',  "pje/caminando/")
   self:addEstado('DASH',  "pje/dash/", Personaje.dashear)
   self:addEstado('ATK1', "pje/boxtest/")

   --Estado actual
   self:setEstado('IDLE')   

   self.scale = 3
   self.rate = 5 -- rate de ciclado de sprites

   --STATUS
   self.orientacionX = Orientaciones.DERECHA

   --POSICION
   self.x = 50
   self.y = SCREEN_HEIGHT*0.4

   self.__index = self


   --Constantes de velocidad
   self.vwalk_x = 270 -- Velocidad de caminar
   self.vwalk_y = -80 --Velocidad de caminar en y
   self.vrun_x = 580 -- Velocidad de correr
   self.vdash = 5500


   print("Personaje creado!")
   print(self.estados['DASH'].accion)
   --print(Personaje.dashear)
   --print(loadSprite)

   return self
end


function Personaje:update(dt)

   --Posicion, frame actual y acciones de estado
   Objeto.update(self, dt)  --OJO: La sintaxis del ":" reemplazando al "self" como 1er parametro no funciona acá, por alguna razon


   --Se fija como actualizar las vars de movimiento
   --self:chequearTeclas(dt) 
   --self:actualizarEstado(dt)

   --Limites de la pantalla
   --self.x = math.clamp(self.x,0, SCREEN_WIDTH - self.currentFrame:getWidth()*self.scale) --Se le podría agregar un "acell = 0 y vel=0" en los casos que choca, si fuera más pro
   --self.y = math.clamp(self.y,0, SCREEN_HEIGHT)

   if Teclas['Pje1_grow'].isDown then self.scale = self.scale + 2*dt end
   if Teclas['Pje1_shrink'].isDown then self.scale = self.scale - 2*dt end


   --Veo si Estoy IDLE: Ninguna tecla pulsada y vengo de un estado de movimieneto
   if self:estaEnEstado({'WALK', 'RUN'}) and not
      (Teclas['Pje1_right'].isDown or Teclas['Pje1_left'].isDown or Teclas['Pje1_up'].isDown or Teclas['Pje1_down'].isDown)
   then
      self:setEstado('IDLE')
      self.velx, self.vely = 0 , 0 
   end

end   

function Personaje:chequearTeclas(dt)

   --Chequeo de movimiento horizontal: Si hay tecla presionada me muevo, si no freno
   if love.keyboard.isDown("right") then self:addAccelX(dt, 1) self.orientacionX = Orientaciones.DERECHA

   elseif love.keyboard.isDown("left") then self:addAccelX(dt, -1)  self.orientacionX = Orientaciones.IZQUIERDA
   else self:frenarX(dt) 
   end


end


------------------------------  COMANDOS MOVIMIENTO ---------------------------------------------


--Recibe un "mover a la derecha"
--Tecla id: 'Pje1_right'
function Personaje:comandoRightPress()

   --Si estoy Idle o moviendome, entro a caminar. Override si estaba yendo a la izquierda
   if self:estaEnEstado({'IDLE', 'WALK'}) then 
      self:setEstado('WALK')
      self.velx = self.vwalk_x
   end

   --Si estoy corriendo vertical, sigo corriendo pero añado velocidad horizontal
   if self:estaEnEstado({'RUN'}) and self.vy ~= 0 then 
      self.velx = self.vwalk_x
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_right']

   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
      self.velx = self.vrun_x
   end

  --print(Teclas['Pje1_right']:calcular_dt(), Teclas['Pje1_right'].last_pressed_time)

end

--Recibe un "mover a la izquierda"
function Personaje:comandoLeftPress()
   if self:estaEnEstado({'IDLE', 'WALK'}) then 
      self:setEstado('WALK')
      self.velx = -self.vwalk_x
   end

   --Si estoy corriendo vertical, sigo corriendo pero añado velocidad horizontal
   if self:estaEnEstado({'RUN'}) and self.vy ~= 0 then 
      self.velx = -self.vwalk_x
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_left']

   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
      self.velx = -self.vrun_x
   end

end


--Recibe un "mover arriba"
function Personaje:comandoUpPress()

   --Si estoy Idle o moviendome, entro a caminar. Override si estaba yendo a la izquierda
   if self:estaEnEstado({'IDLE', 'WALK'}) then 
      self:setEstado('WALK')
      self.vely = self.vwalk_y
   end

   --Si estoy corriendo horizontal, sigo corriendo pero añado velocidad vert
   if self:estaEnEstado({'RUN'}) and self.vx ~= 0 then 
      self.vely = self.vwalk_y
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_up']

   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
      self.vely = self.vrun_y
   end

end

function Personaje:comandoDownPress()
      
   --Si estoy Idle o moviendome, entro a caminar. Override si estaba yendo a la izquierda
   if self:estaEnEstado({'IDLE', 'WALK'}) then 
      self:setEstado('WALK')
      self.vely = -self.vwalk_y
   end

   --Si estoy corriendo horizontal, sigo corriendo pero añado velocidad vert
   if self:estaEnEstado({'RUN'}) and self.vx ~= 0 then 
      self.vely = -self.vwalk_y
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_up']

   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUN')
      self.vely = -self.vrun_y
   end
end





--Recibe un "ya no se mueve a la derecha"
function Personaje:comandoRightRelease()
   
   local tecla = Teclas['Pje1_right']

   --Veo si puedo empezar un Dash
   dt_release = tecla:dt_last_press()
   if self:estaEnEstado({'RUN'}) and dt_release < dt_DASH then
         self:dashear()
         return
   end


   --Si está presionada la tecla de izq, voy para allá
   if Teclas['Pje1_left'].isDown then self:comandoLeftPress(); return end


   --Si estoy yendo a la derecha, paro el mvt horizontal
   --Tendria que chequear acá si sigue el mvt vertial
   if self:estaEnEstado({'WALK', 'RUN'}) and self.velx > 0 then 
      self:setEstado('IDLE')
      self.velx = 0
      return
   end

end

--Recibe un "ya no se mueve a la izquierda"
function Personaje:comandoLeftRelease()
   if self:estaEnEstado({'WALK', 'RUN'}) and self.velx < 0 then 
      self:setEstado('IDLE')
      self.velx = 0
   end

   --Si está presionada la tecla de der, voy para allá
   if Teclas['Pje1_right'].isDown then self:comandoRightPress() end
end



--Recibe un "ya no se mueve arriba"
function Personaje:comandoUpRelease()
   if self:estaEnEstado({'WALK', 'RUN'}) and self.vely < 0 then 
      self:setEstado('IDLE')
      self.vely = 0
   end

   --Si está presionada la tecla de der, voy para allá
   if Teclas['Pje1_right'].isDown then self:comandoRightPress() end

end

--Recibe un "ya no se mueve abajo"
function Personaje:comandoDownRelease()
   if self:estaEnEstado({'WALK', 'RUN'}) and self.vely > 0 then 
      self:setEstado('IDLE')
      self.vely = 0
   end

   --Si está presionada la tecla de der, voy para allá
   if Teclas['Pje1_right'].isDown then self:comandoRightPress() end

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


--Acá se maneja todo el dasheo
-- La idea es que hay un timer y que la velocidad y cuando termina el dash dependen de este timer 
-- tambien se controla la animacion desde acá
function Personaje:dashear(dt)

   --Si entro al dash desde otro estado: Empiezo el timer
   --Esta logica se puede rehacer, para no llamar a esta funcion en las teclas sino solo a setearEstado
   if self.estado.name ~= 'DASH' then
      self:setEstado('DASH')
      self.dash_timer = 0
      self.scale = 1
      return
   end

   --Si el dash terminó: vuelvo a Idle
   if self.dash_timer >= dash_timer_max then
      self:setEstado('IDLE')
      self.scale = 3
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


--Se llama al entrar en un walk
function Personaje:caminar(dir)



end