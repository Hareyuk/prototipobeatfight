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


--Constructor
function Personaje:new(id)
   print("Creando personaje: " .. id)


   local self = setmetatable(Objeto:new('Personaje ' .. id), Personaje) --Crea una instancia de objeto. Asi tiene coord x, y, etc

   --SPRITES
   self:addEstado('IDLE', "pje/reposo/")
   self:addEstado('WALK', "pje/caminando/")
   self:addEstado('RUN',  "pje/caminando/")
   
   self:setEstado('IDLE')   

   self.scale = 3
   self.rate = 5 -- rate de ciclado de sprites

   --STATUS
   self.orientacionX = Orientaciones.DERECHA

   --POSICION
   self.x = 50
   self.y = SCREEN_HEIGHT*0.4

   --Constantes de velocidad
   self.vwalk_x = 100 -- Velocidad de caminar
   self.vwalk_y = -40 --Velocidad de caminar en y
   self.vrun_x = 200 -- Velocidad de correr

   self.__index = self

   print("Personaje creado!")

   return self
end


function Personaje:update(dt)

-- Actualizar Posición del pje (automático)
   Objeto:updatePosition(dt)
   
   --Se fija como actualizar las vars de movimiento
   self:chequearTeclas(dt) 
   self:actualizarEstado(dt)



   --Limites de la pantalla
   self.x = math.clamp(self.x,0, SCREEN_WIDTH - self.currentFrame:getWidth()*self.scale) --Se le podría agregar un "acell = 0 y vel=0" en los casos que choca, si fuera más pro
   self.y = math.clamp(self.y,0, SCREEN_HEIGHT)

end   

function Personaje:chequearTeclas(dt)

   --Chequeo de movimiento horizontal: Si hay tecla presionada me muevo, si no freno
   if love.keyboard.isDown("right") then self:addAccelX(dt, 1) self.orientacionX = Orientaciones.DERECHA

   elseif love.keyboard.isDown("left") then self:addAccelX(dt, -1)  self.orientacionX = Orientaciones.IZQUIERDA
   else self:frenarX(dt) 
   end


end

------------------------  COMANDOS MOVIMIENTO ---------------------------------------------

dt_RUN = 400 --ms. Tiempo maximo permitido entre dos aprietes de tecla consecutivos para empezar a correr
dt_DASH = 400 --ms. Tiempo maximo permitido para soltar la tecla desde la ultima apretada para ver si corre o dashea


--Recibe un "mover a la derecha"
--Tecla id: 'Pje1_right'
function Personaje:comandoRightPress()

   --Si estoy Idle o moviendome, entro a caminar. Override si estaba yendo a la izquierda
   if self:estaEnEstado({'IDLE', 'WALK', 'RUN'}) then 
      self:setEstado('WALK')
      self.velx = self.vwalk_x
      print('WALK!')
   end

   --Veo si puedo empezar un RUN
  --print(Teclas['Pje1_right']:calcular_dt(), Teclas['Pje1_right'].last_pressed_time)

   if self:estaEnEstado({'IDLE', 'WALK', 'RUN'}) and Teclas['Pje1_right']:calcular_dt()< dt_RUN then
      self:setEstado('RUN')
      self.velx = self.vrun_x
      print('RUN!!')
   end

end

--Recibe un "mover a la izquierda"
function Personaje:comandoLeftPress()
   if self:estaEnEstado({'IDLE', 'WALK', 'RUN'}) then 
      self:setEstado('WALK')
      self.velx = -self.vwalk_x
   end

   --Veo si puedo empezar un RUN
   dt_tecla = love.timer.getTime() - Teclas['Pje1_left'].last_pressed_time
   if self:estaEnEstado({'IDLE'}) and (dt_tecla < dt_RUN) then
      self.setEstado('RUN')
      self.vx = -self.vrun_x
   end
end


--Recibe un "mover arriba"
function Personaje:comandoUpPress()

   --Si estoy Idle o moviendome, entro a caminar. Override si estaba yendo a la izquierda
   if self:estaEnEstado({'IDLE', 'WALK', 'RUN'}) then 
      self:setEstado('WALK')
      self.vely = self.vwalk_y
   end
end




--Recibe un "ya no se mueve a la derecha"
function Personaje:comandoRightRelease()
   
   --Veo si puedo empezar un Dash


   --Si estoy yendo a la derecha, paro
   if self:estaEnEstado({'WALK', 'RUN'}) and self.velx > 0 then 
      self:setEstado('IDLE')
      self.velx = 0
   end

   --Si está presionada la tecla de izq, voy para allá
   if Teclas['Pje1_left'].isDown then self:comandoLeftPress() end



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


function Personaje:keypressed(key)
   if key == 'right' then self.velx = self.velx + self.v0
      self.orientacionX = Orientaciones.DERECHA

   elseif key == 'left' then self.velx = self.velx - self.v0
      self.orientacionX = Orientaciones.IZQUIERDA 
   end
end


