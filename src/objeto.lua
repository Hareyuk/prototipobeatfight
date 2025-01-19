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

function Objeto:mostrarBox(boxtype)

   local frame = self.estado:getCurrentFrame()
   local box = frame[boxtype]

   if not box then return end --si no hay hitbox aca se acabo la joda

   love.graphics.push()

   local alpha = 0.3
   if(boxtype == 'hitbox') then love.graphics.setColor(1,0,0, alpha)
   elseif (boxtype == 'hurtbox') then love.graphics.setColor(0,0,1, alpha)
   elseif (boxtype == 'collisionbox') then  love.graphics.setColor(0,1,0, alpha)
   end

   love.graphics.rectangle('line', self.x + box.x, self.y + box.y, box.w*self.scale, box.h *self.scale) 
   
   love.graphics.pop()
end


function Objeto:mostrarHitbox()
   self:mostrarBox('hitbox')
end

function Objeto:mostrarHurtbox()
   self:mostrarBox('hurtbox')
end

function Objeto:mostrarCollisionbox()
    self:mostrarBox('collissionbox')
end

--Lo hago asi en vez de llamar uno por uno en love.update()
--para que otros objetos puedan overridear esta funcion agregandole mas cosas si necesitan
function Objeto:update(dt)
   print('Haciendo update de ' .. self.name, 'estado '.. self.estado.name)
   self:ciclarFrames(dt)
   self:updatePosition(dt)
   self:updateAccion(dt)
end

--Acá repensar luego, porque el orden en que se dibujan las cosas sí importa y mucho...
-- Y tambien calcular si el personaje aparece en pantalla o no (ej "es visible")
function Objeto:drawFrame()

   print('Dibujando '.. self.name ..' | frame de estado ' .. self.estado.name)
   if(not self:esVisible()) then return end 

   local sp = self:getCurrentFrame().imagen --sprite a dibujar, es una imagen
   local w = sp:getWidth() * self.scale
   local h = sp:getHeight() * self.scale

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


end


function Objeto:esVisible()


   return true
end

--Muestra las coordenadas propias en pantalla para mayor comodidad
function Objeto:mostrarCoords()


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

   local hbox = self.estado:getCurrentFrame().hitbox 
   if hbox then hbox:mostrarCoords() end


   return
end


--Devuelve el objeto Frame actual
function Objeto:getCurrentFrame()
   return self.estado:getCurrentFrame()
end 