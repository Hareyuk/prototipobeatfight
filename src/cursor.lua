--cursor = Objeto:new('cursor')  -- Esto está bien, como va a haber siempre una unica instancia de Cursor puede ir esto

Cursor = setmetatable({}, Objeto)  -- Y esto es por si quiero heredar propiamente la clase y crear una nueva
Cursor.__index = Cursor

require "objeto" --funciones de sprites generales
--No usa todo, como vx, vy, esas cosas, solo pos

function Cursor:crear()

   print("Creando cursor")
   --local self = setmetatable(Objeto:new('Cursor'), Cursor) --Crea una instancia de objeto. Asi tiene coord x, y, etc
   local self = Objeto:new('Cursor')
   setmetatable(self, {__index = Cursor}) --Crea una instancia de objeto. Asi tiene coord x, y, etc


   self:addEstado('cora1', "cursor/cora1/")
   self:addEstado('cora2', "cursor/cora2/")
   self:addEstado('cora3', "cursor/cora3/")
   self:addEstado('cora4', "cursor/cora4/")

   self:setEstado('cora1')


   self.scale = 0.2
   self.cursor_i = 1
  
  -- self.currentStateFrames = self.frames --unico estado, es redundante esta linea. Pero por claridad lo separé así
   --self.currentFrame_t = 1 -- contador de frame actual (puede ser decimal, se redondea aparte)
   self.rate = 5 -- velocidad a la que cambia los frames

   print("Cursor creado!")

   return self

end

--Override la de la clase Objeto
function Cursor:updatePosition(dt)
   self.prev_x, self.prev_y = self.x, self.y
   self.x, self.y = camera:mousePositionCentered() 
   --self.x, self.y = love.mouse.getX(), love.mouse.getY()
end

function Cursor:cambiarCursor()
   --self.cursor_i = (self.cursor_i % #self.sprites)  + 1
   --self.currentStateFrames = self.sprites[self.cursor_i] --Esto es identico al codigo y logica de cambiar fondo, podria reciclarse la verdad.
end  
