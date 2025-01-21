function cargarMusica()
   musica = love.audio.newSource("Scheherazade.mp3", "stream") 
   musica:setLooping(true)
   musica:play()
   -- the "stream" tells LÖVE to stream the file from disk, good for longer music tracks (.ogg)
   -- the "static" tells LÖVE to load the file into memory, good for short sound effects (.wav)
end

--Hay un solo escenario activo en todo momento, asi que lo creamos como instancia unica
Escenario = {}

Fondo = setmetatable({}, Objeto)  -- Y esto es por si quiero heredar propiamente la clase y crear una nueva
Fondo.__index = Fondo

function Fondo:crear()
   print("Creando Fondo:")
   local self = Objeto:new('Fondo')
   setmetatable(self, {__index = Fondo}) --Crea una instancia de objeto. Asi tiene coord x, y, etc

   self:addEstado('castillo1', "fondos/castle1/")
   self:addEstado('castillo2', "fondos/castle2/")
   
   self:setEstado('castillo1')

   self.fondo_i = 1
   self.rate = 3

   print(self.estado.name)
   print("Fondo creado!")
   return self
end


function Fondo:update(dt)
   --No hay movimiento ni otras cosass
   self:ciclarFrames(dt)
end

function Fondo:cambiarFondo()
   self.fondo_i = (self.fondo_i % #self.sprites)  + 1
   self.currentStateFrames = self.sprites[Fondo.fondo_i]
end  
   

function Fondo:draw()
   drawImage(self:getFrameActual().imagen, 0, 0, 2*SCREEN_WIDTH, 2*SCREEN_HEIGHT)
end



--------------------------- OBJETOS DE ESCENARIO   ----------------------------


Columna = setmetatable({}, Objeto)  -- Y esto es por si quiero heredar propiamente la clase y crear una nueva
Columna.__index = Columna

function Columna:new(x, y)

   print("Creando columna")
   --local self = setmetatable(Objeto:new('Cursor'), Cursor) --Crea una instancia de objeto. Asi tiene coord x, y, etc
   local self = Objeto:new('Columna')
   setmetatable(self, {__index = Columna}) --Crea una instancia de objeto. Asi tiene coord x, y, etc


   self:addEstado('Idle', 'col_rota/')

   self:setEstado('Idle')

   self.x, self.y = x,y

   return self

end
