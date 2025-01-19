--Modulo general de objetos. Todo lo que se muestre en pantalla con sprites es un objeto

--id = 0 -- Le asigna un id de objeto a todos los objetos. Util por si despues se quiere debugear

Objeto = {x = 0, y  = 0,
         velx = 0, vely = 0,
         accx = 0, accy = 0,
         scale = 1,
         estados = {}, --array de Estados
         estado = nil,  --estado actual. Una instancia de Estado, referencia a un elemento de self.estados
         orientacionX = 0,  --1,2,3 o 4. Ver abajo. RRepensar con 1 y -1
         name = '', -- Nombre propio. Que objeto es
         debug = false --Para cosas como mostrar su ubicacion, valor de atributos, etc
      }

Objeto.__index = Objeto --Crea clase

Orientaciones = {DERECHA = 0, ABAJO = 1, IZQUIERDA = 2, ARRIBA = 3}

--[[ Por si se quiere optimizar mas
Objeto_idle = {
   x = 0, y = 0,
   scale = 1,
   currentFrame_t = 1,
   currentFrame =
}
]]


--Constructor de objeto
function Objeto:new(name)
    local self = setmetatable({}, Objeto)
    self.name = name or ''

    print('Objeto '.. name .. ' creado')
  return self
end

--Asignacion de estados
require "estados"
function Objeto:addEstado(nombre, path_sprites)
   self.estados[nombre] = Estado:new(nombre, path_sprites)
end

--Recibe un array de frames para ya dibujar ese estado actual.
--function Objeto:setSprites(frames, framei = 1, rate = self.rate)

function Objeto:setEstado(estadoName, framei, rate)

   self.estado = self.estados[estadoName]
   self.estado.rate = rate  or self.rate -- rate de ciclado de sprites.

   self.estado.currentFrame_t = 0 -- timer

  --print(self.estado.name)

end

--Se fija si el nombre del estado actual es alguno de los de la lista
function Objeto:estaEnEstado(lista)
   return estaEn(lista, self.estado.name)
end


function Objeto:updateAccion(dt)
   --print('Haciendo '.. self.estado.name)
   self.estado:accion(dt) --si el estado actual hace algo especial, se pide acá
end


-- Actualiza x e y segun vel, acc, etc
function Objeto:updatePosition(dt) 

   self.x = self.x + self.velx*dt
   self.y = self.y + self.vely*dt

   self.velx = self.velx + self.accx*dt
   self.vely = self.vely + self.accy*dt

end

--Avanza los frames segun haga falta
function Objeto:ciclarFrames(dt)
   self.estado:ciclarFrames(dt)
end


--Todo revisar lo de las escalas, se recontra rompe 
function Objeto:mostrarBox(boxtype) --muestra uno de los tres tipos de hitbox, con su color y todo

   local frame = self:getFrameActual()
   local box = frame[boxtype] --esto es como hacer frame.hurtbox y asi. Sintaxis rota

   if not box then return end --si no hay hitbox aca se acabo la joda

   love.graphics.push('all')

   local alpha = 0.8
   if(boxtype == 'hitbox') then love.graphics.setColor(1,0,0, alpha)
   elseif (boxtype == 'hurtbox') then love.graphics.setColor(0,0,1, alpha)
   elseif (boxtype == 'collisionbox') then  love.graphics.setColor(0,1,0, alpha)
   end

   --print(box.x, box.y, box.w, box.h)
   --print(self.x + box.x*self.scale, self.y + box.y*self.scale, box.w*self.scale, box.h*self.scale)

   love.graphics.rectangle('fill', self.x + box.x*self.scale
                                 , self.y + box.y*self.scale
                                 , box.w*self.scale
                                 , box.h*self.scale) 
   
   love.graphics.pop()
end


function Objeto:mostrarHitbox()
   self:mostrarBox('hitbox')
end

function Objeto:mostrarHurtbox()
   self:mostrarBox('hurtbox')
end

function Objeto:mostrarCollisionbox()
    self:mostrarBox('collisionbox')
end

--Lo hago asi en vez de llamar uno por uno en love.update()
--para que otros objetos puedan overridear esta funcion agregandole mas cosas si necesitan
function Objeto:update(dt)
   --print('Haciendo update de ' .. self.name, 'estado '.. self.estado.name)
   self:ciclarFrames(dt)
   self:updatePosition(dt)
   self:updateAccion(dt)
end

--Acá repensar luego, porque el orden en que se dibujan las cosas sí importa y mucho...
-- Y tambien calcular si el personaje aparece en pantalla o no (ej "es visible")
function Objeto:drawFrame()

   --print('Dibujando '.. self.name ..' | frame de estado ' .. self.estado.name)
   if(not self:esVisible()) then return end 

   love.graphics.push('all')

   --love.graphics.scale(self.scale)

   local sp = self:getFrameActual().imagen --sprite a dibujar, es una imagen
   local w = sp:getWidth() * self.scale
   local h = sp:getHeight() * self.scale

   --local w = sp:getWidth() 
   --local h = sp:getHeight()

   
   --El pje mira hacia la derecha o acelera a la derecha
   if self.orientacionX == Orientaciones.DERECHA  then
      drawImage(sp, self.x, self.y, w, h, 0,0)
   end

   --El pje mira hacia la izquierda
   if self.orientacionX == Orientaciones.IZQUIERDA then
      drawImage(sp, self.x, self.y, -w, h, sp:getWidth(),0)
   end


   if(DEBUG) then
      self:mostrarCoords()
      end

   love.graphics.pop()

end


function Objeto:esVisible()


   return true
end

--Muestra las coordenadas propias en pantalla para mayor comodidad
function Objeto:mostrarCoords()


   love.graphics.push('all')

   --love.graphics.translate(self.x, self.y)
   --love.graphics.scale(self.scale)

   love.graphics.setFont(fontDebug)

   local MOSTRAR_EN_PJE = true -- Las muestra en la misma posicion del personaje

   local x = string.format("%.2f", self.x)
   local y = string.format("%.2f", self.y)

   if MOSTRAR_EN_PJE then 

      local coords = "x: " .. x .. "\ny: " .. y
      local color_texto = {235/255,20/255,20/255} --rojo
      local limite_pix = 350 --limite antes del wrap
      local pos = love.math.newTransform(self.x, self.y) -- x e y
      love.graphics.printf( {color_texto,coords} , pos, limite_pix, "left" )  

   else --Las muestra abajo en un lugar fijo de la pantalla

   end

   --local hbox = self.estado:getFrameActual().hitbox 
   --if hbox then hbox:mostrarCoords() end

   love.graphics.pop()

   return
end


--Devuelve el objeto Frame actual
function Objeto:getFrameActual()
   return self.estado:getFrameActual()
end 


-------------------------------------- DETECCION DE COLISIONES -- LOGICA


--La idea es: Un objeto con frame de hit se fija si está chocando a otro objeto con frame de hurt
--TODO: sacar los scales y chau. Es un quilombo trabajar siempre con eso
--Si está hiteando, envía la información del hit a ambos objetos
function Objeto:checkEstaHiteando(otroObjeto)
      
   local htbox = self:getFrameActual().hitbox 

   if htbox then -- este chequeo se supone que es redundante, porque ya lo hice antes de llamar. Puede volar
      local hurtbox = otroObjeto:getFrameActual().hurtbox
      if hurtbox then
         return chequearColision(htbox.x*self.scale + self.x,
                                 htbox.y*self.scale + self.y,
                                 htbox.w*self.scale,
                                 htbox.y*self.scale,
                                 hurtbox.x*otroObjeto.scale + otroObjeto.x,
                                 hurtbox.y*otroObjeto.scale + otroObjeto.y,
                                 hurtbox.w*otroObjeto.scale,
                                 hurtbox.y*otroObjeto.scale
                                 )
      end
   end

   return false
end

function Objeto:checkHit(otroObjeto)

   if not self:checkEstaHiteando(otroObjeto) then return end

   print('Ataque de ' ..self.name .. ' a '..otroObjeto.name)

end


function Objeto:checkMovt(otroObjeto)

   if not false then return end

   print('Solapamiento de ' ..self.name .. ' a '..otroObjeto.name)

end