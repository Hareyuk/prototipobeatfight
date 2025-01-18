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
   
   self:setEstado('IDLE')   

   self.scale = 3
   self.rate = 5 -- rate de ciclado de sprites

   --STATUS
   self.orientacionX = Orientaciones.DERECHA

   --POSICION
   self.x = 50
   self.y = SCREEN_HEIGHT*0.4

   --Constantes de velocidad
   self.accSpeedX = 300 -- Constante que define la aceleración
   self.maxVel = 400
   self.vwalk = 100 -- Velocidad de caminar

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

--Recibe un "mover a la derecha"
function Personaje:comandoRightPress()

   --Si estoy Idle o moviendome, entro a caminar. Override si estaba yendo a la izquierda
   if estaEn({'IDLE', 'WALK', 'RUN'}, self.estado.name) then 
      self:setEstado('WALK')
      self.velx = self.vwalk
   end
end


--Recibe un "mover a la izquierda"
function Personaje:comandoLeftPress()
   if estaEn({'IDLE', 'WALK', 'RUN'}, self.estado.name) then 
      self:setEstado('WALK')
      self.velx = -self.vwalk
   end
end


--Recibe un "ya no se mueve a la derecha"
function Personaje:comandoRightRelease()
   --Si estoy yendo a la derecha, paro
   if (self.estado.name == 'WALK' or self.estado.name == 'RUN') and self.velx > 0 then 
      self:setEstado('IDLE')
      self.velx = 0
   end

   --Si está presionada la tecla de izq, voy para allá
   if Teclas['Pje1_left'].isDown then self:comandoLeftPress() end

end



--Recibe un "ya no se mueve a la izquierda"
function Personaje:comandoLeftRelease()
   if (self.estado.name == 'WALK' or self.estado.name == 'RUN') and self.velx < 0 then 
      self:setEstado('IDLE')
      self.velx = 0
   end

   --Si está presionada la tecla de der, voy para allá
   if Teclas['Pje1_right'].isDown then self:comandoRightPress() end

end

















--Cambiar
function Personaje:actualizarEstado(dt)

   --Si su vel es alta, es pq está caminando

   if(self.STATUS == Pje_Status.IDLE)  then self.currentStateFrames = self.sprites.idle end
   if(self.STATUS == Pje_Status.WALK)  then self.currentStateFrames = self.sprites.caminando end


end

function Personaje:keypressed(key)
   if key == 'right' then self.velx = self.velx + self.v0
      self.orientacionX = Orientaciones.DERECHA

   elseif key == 'left' then self.velx = self.velx - self.v0
      self.orientacionX = Orientaciones.IZQUIERDA 
   end
end


