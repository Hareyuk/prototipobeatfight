require "objeto" 


--Creo la clase Personaje como Hija de Objeto. Las cosas nuevas las agrego abajo, en el "constructor" (el nombre "new" es generico, no necesario)
--Personaje = Objeto:new()
Spikeball = setmetatable({}, Objeto)
Spikeball.__index = Spikeball


--CONSTANTES DE VELOCIDAD Y MOVIMIENTO
Spikeball_weight = 10 --masa. Afecta a la velocidad de su knockback

--Cuando la bola está en movimiento, puede golpear (entra en estado con hitbox: LANZADA)
--Constructor
function Spikeball:new(id, x,y)
   self.id = id or objids+1

   print("Creando Spikeball: " .. self.id)

   local self = Objeto:new('Spikeball')
   setmetatable(self, {__index = Spikeball}) 
   self.__index = self

   --SPRITES
   self:addEstado('IDLE', "spikeball/", Spikeball.initIdle, nil, nil)
   self:addEstado('LANZADA', "spikeball/", Spikeball.initLanzada, Spikeball.updateLanzada, nil)

   
   --Estado actual
   self:setEstado('IDLE')   
   self.orientacion = nil


   self:setScale(0.5)
   self.rate = 5 -- rate de ciclado de sprites

   --POSICION
   self.x = SCREEN_WIDTH
   self.y = SCREEN_HEIGHT

   self.acc_ang = 0 --aceleracion angular
   self.vel_ang = 0 --velocidad angular
   self.ang = 0 --angulo actual

   print("Spikeball creada!")
   
   return self
end

function Spikeball:initIdle()
   self.velx , self.vely = 0,0
   self.accx, self.accy = 0,0
   self.vel_ang, self.acc_ang = 0,0
end

function Spikeball:initLanzada()

end


--Funcion de estado. La posicion se updatea aparte en la de objeto
function Spikeball:updateLanzada(dt)

   print('Vel: ', self.velx, self.vely)

   --Update Rotacion
   self.ang = self.ang + self.vel_ang*dt
   self.vel_ang = self.vel_ang  + self.acc_ang* dt

   self.acc_ang = self.acc_ang*(1-dt)/(1+dt*Spikeball_weight) --Hago el freno proporcional a la masa

   --Todo proporcional a la masa y velocidad 
   self.atkKnockback = 0

   --Voy frenando:  a = -k.v
   self.accx = -self.velx*Spikeball_weight
   self.accy = -self.vely*Spikeball_weight


   --Todo: Veo si ya está frenada para sacar el hitbox y poner en Idle
   self.velx = math.reduceto0(self.velx, 1)
   self.vely = math.reduceto0(self.vely, 1)
   if(self.velx == 0 and self.vely == 0) then self:setEstado('IDLE') end

end


function Spikeball:drawFrame()
   local img = self:getFrameActual().imagen


   local w, h = img:getWidth(), img:getHeight()
   
   --Dibuja rotando alrededor del centro
   love.graphics.draw(img, self.x +self.w/2, self.y+self.h/2, self.ang, self.scale, self.scale, w/2, h/2)



   if(DEBUG) then
      self:mostrarCoords()
      self:mostrarBordes()
      self:mostrarCentro()


      self:mostrarHurtbox()
      self:mostrarCollisionbox()
      self:mostrarHitbox()
      
   end

end


--Se llama cuando el personaje la hitea
function Spikeball:recibirHit(pje)

   self:setEstado('LANZADA')

   --Calcular rotacion: Asigno velocidad angular basandome en el torque
   local pje_hbox = pje:getFrameActual().hitbox

   local rx, ry = self.x - pje_hbox.x, self.y-pje_hbox.y --Vector entre el centro de la bola y el centro del hitbox que golpeó
   local r = math.sqrt(rx*rx + ry*ry) --||r||

   local Fx, Fy = 0, 0 --Vector fuerza del golpe, proporcional al knockback del hit.

   if(pje.orientacion == 'Arriba') then Fx, Fy = 0,1 
   elseif(pje.orientacion == 'Abajo') then Fx, Fy = 0,-1
   elseif(pje.orientacion == 'Derecha') then Fx, Fy = 1,0
   elseif(pje.orientacion == 'Izquierda') then Fx, Fy = -1, 0 end

   local F = math.sqrt(Fx*Fx + Fy*Fy)*pje.atkKnockback --||F||

   --Saco rxF para averiguar |r x F|, que me da el angulo. La coordenada z alcanza
   local rxF_z = rx*Fy - ry*Fx

   --self.vel_ang = r*F*sin(theta) No tengo el angulo
   self.vel_ang = rxF_z / Spikeball_weight

end