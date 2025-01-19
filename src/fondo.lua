function cargarMusica()
   musica = love.audio.newSource("Scheherazade.mp3", "stream") 
   musica:setLooping(true)
   musica:play()
   -- the "stream" tells LÖVE to stream the file from disk, good for longer music tracks (.ogg)
   -- the "static" tells LÖVE to load the file into memory, good for short sound effects (.wav)
end

--Hay un solo escenario activo en todo momento, asi que lo creamos como instancia unica
Escenario = {}

Fondo = {}

function Fondo:crear()
   print("Creando Fondo:")

   self = Objeto:new('Fondo')


   self.sprites = {} --array de array de sprites
   self.sprites[1] = loadSprites("Fondos/gatos/")
   self.sprites[2] = loadSprites("Fondos/slam/")
   self.sprites[3] = loadSprites("Fondos/burro/")
   self.sprites[4] = loadSprites("Fondos/kirby/")

   self:setSprites(self.sprites[1])

   --image1 = love.graphics.newImage("madoka.png") --SOLO ACEPTA PNGs!!!
   --image2 = love.graphics.newImage("kirby.png")
   --image3 = love.graphics.newImage("hamster.png") 

   self.fondo_i = 1
   self.rate = 3

   print("Fondo creado!")
end


function Fondo:update(dt)
   self:ciclarFrames(dt)
end

function Fondo:cambiarFondo()
   self.fondo_i = (self.fondo_i % #self.sprites)  + 1
   self.currentStateFrames = self.sprites[Fondo.fondo_i]
end  
   

function Fondo:draw()
   --Color del Fondo (cambio el de slam a rosa)
  r, g, b, a = love.graphics.getColor() -- anteriores

  --Le cambio el color al Fondo de slam dunk y el de Kirby
  if Fondo.fondo_i == 2 or Fondo.fondo_i == 4
   then love.graphics.setColor(235/255,20/255,220/255) --rosa  
   end 

   drawImage(Fondo.currentFrame, 0, 0, WIDTH, HEIGHT)
   love.graphics.setColor(r,g,b,a) --Restauro colores originales
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
