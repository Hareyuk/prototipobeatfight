cursor = Objeto:new('cursor')  -- Esto está bien, como va a haber siempre una unica instancia de Cursor puede ir esto

--cursor = setmetatable({}, Objeto)   Y esto es por si quiero heredar propiamente la clase y crear una nueva
--cursor.__index = Personaje

require "objeto" --funciones de sprites generales
--No usa todo, como vx, vy, esas cosas, solo pos

function cursor:crear()

   print("Creando cursor")

   self.sprites = {}
   self.sprites[1] = loadSprites("cursor/cora1/")
   self.sprites[2] = loadSprites("cursor/cora2/")
   self.sprites[3] = loadSprites("cursor/cora3/")
   self.sprites[4] = loadSprites("cursor/cora4/")

   self:setSprites(self.sprites[1])


   self.scale = 0.2
   self.cursor_i = 1
  
  -- self.currentStateFrames = self.frames --unico estado, es redundante esta linea. Pero por claridad lo separé así
   --self.currentFrame_t = 1 -- contador de frame actual (puede ser decimal, se redondea aparte)
   self.rate = 5 -- velocidad a la que cambia los frames

   print("Cursor creado!")

end

--Override la de la clase Objeto
function cursor:updatePosition(dt)
   self.x, self.y = camera:mousePosition() 
end

function cursor:cambiarCursor()
   self.cursor_i = (self.cursor_i % #self.sprites)  + 1
   self.currentStateFrames = self.sprites[self.cursor_i] --Esto es identico al codigo y logica de cambiar fondo, podria reciclarse la verdad.
end  
