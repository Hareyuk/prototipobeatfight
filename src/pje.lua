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
   RUNX  = 3.5,
   RUNY = 3.6,
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
   self:addEstado('RUNX',  "pje/caminando/")
   self:addEstado('RUNY',  "pje/caminando/")

   self:addEstado('DASH',  "pje/dash/", Personaje.dashear)
   self:addEstado('ATK1', "pje/boxtest/")

   --Estado actual
   self:setEstado('IDLE')   

   self.scale = 3
   self.rate = 5 -- rate de ciclado de sprites

   --STATUS
   self.orientacionX = Orientaciones.DERECHA

   --POSICION
   self.x = S
   self.y = SCREEN_HEIGHT*1.4

   self.__index = self


   --Constantes de velocidad
   self.vwalk_x = 270 -- Velocidad de caminar
   self.vwalk_y = 80 --Velocidad de caminar en y
   self.vrun_x = 580 -- Velocidad de correr
   self.vrun_y = 140 -- Velocidad de correr

   self.vdash = 5500


   print("Personaje creado!")
   print(self.estados['DASH'].accion)
   --print(Personaje.dashear)
   --print(loadSprite)

   return self
end


--TODO todos los chequeos de teclas tienen que indexarse de otra manera
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


   --Si estoy caminando, asigno la velocidad según las teclas presionadas
   if self:estaEnEstado({'WALK'}) then
      self:chequearTeclasMovimientoWalk()
   end

   --Si estoy corriendo en X, veo que pasa con Y
   if self:estaEnEstado({'RUNX'}) then
      self:chequearTeclasMovimientoRunX()
   end


   --Si estoy corriendo en Y, veo que pasa con X
   if self:estaEnEstado({'RUNY'}) then
      self:chequearTeclasMovimientoRunY()
   end


   --[[
   --Veo si Estoy IDLE: Ninguna tecla pulsada y vengo de un estado de movimieneto
   if self:estaEnEstado({'WALK', 'RUN'}) and not
      (Teclas['Pje1_right'].isDown or Teclas['Pje1_left'].isDown or Teclas['Pje1_up'].isDown or Teclas['Pje1_down'].isDown)
   then
      self:setEstado('IDLE')
      self.velx, self.vely = 0 , 0 
   end
   ]]

   --Veo si estoy IDLE: si mi vel es 0
   if self:estaEnEstado({'WALK', 'RUNX', 'RUNY'}) and 
      self.velx == 0 and self.vely == 0
   then
      self:setEstado('IDLE')
      self.velx, self.vely = 0 , 0 
   end


end   

--Asigno velocidad y sprites cuando camino y corro según las teclas que estén pulsadas
--Esto resume las tres funciones de "movimiento logica 1.txt" de demo
--Todo falta asignas sprites
function Personaje:chequearVelocidadDeMovimiento(vx, vy)

   self.velx = 0
   self.vely = 0


   if Teclas['Pje1_right'].isDown then self.velx = self.velx + vx end
   if Teclas['Pje1_left'].isDown then self.velx = self.velx - vx end
   if Teclas['Pje1_up'].isDown then self.vely = self.vely - vy end
   if Teclas['Pje1_down'].isDown then self.vely = self.vely + vy end

   --Todo normalizar segun walk o run
   return

end

function Personaje:chequearTeclasMovimientoWalk()
   self:chequearVelocidadDeMovimiento(self.vwalk_x, self.vwalk_y)
end

--Asigno velocidad y sprites cuando corro horizontal
function Personaje:chequearTeclasMovimientoRunX()
   self:chequearVelocidadDeMovimiento(self.vrun_x, self.vwalk_y)
 end

--Asigno velocidad y sprites cuando corro vertical
function Personaje:chequearTeclasMovimientoRunY()
   self:chequearVelocidadDeMovimiento(self.vwalk_x, self.vun_y)
end

------------------------------  COMANDOS MOVIMIENTO ---------------------------------------------



------------------------------  PRESS

--Idea: Para el mvt: Cada ciclo, setear v = 0, y sumar en direccion por cada boton pulsado.
--Luego normalizar el vector a la speed del personaje

--Recibe un "mover a la derecha"
--Tecla id: 'Pje1_right'
function Personaje:comandoRightPress()

   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_right']
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUNX')
   end

  --print(Teclas['Pje1_right']:calcular_dt(), Teclas['Pje1_right'].last_pressed_time)

end

--Recibe un "mover a la izquierda"
function Personaje:comandoLeftPress()

   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_left']
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUNX')
   end
end


--Recibe un "mover arriba"
function Personaje:comandoUpPress()

   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_up']
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUNY')
   end

end

function Personaje:comandoDownPress()
      
   --Si estoy Idle, entro a caminar
   if self:estaEnEstado({'IDLE'}) then 
      self:setEstado('WALK')
   end

   --Veo si puedo empezar un RUN
   local tecla = Teclas['Pje1_down']
   if self:estaEnEstado({'IDLE', 'WALK'}) and tecla:dt_last_press()< dt_RUN then
      self:setEstado('RUNY')
   end
end


------------------------------  RELEASE



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