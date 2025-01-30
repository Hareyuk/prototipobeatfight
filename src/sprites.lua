--Funciones universales de manejo de sprites que no puedo no tener

--Le pasas un path (a un directorio lleno de .pngs) 
--Te devuelve un array que tiene las love.Image creadas a partir de los png
function loadSprites(carpeta)

   sprites = {}

   files = love.filesystem.getDirectoryItems(carpeta)
   for i, file in ipairs(files) do
      sprites[#sprites+1] = love.graphics.newImage(carpeta .. file)
   end
   --This works because the # operator computes the length of the list. The empty list has length 0, etc.

   return sprites
end

-----------------------BOX

--Coordenadas relativas al (x,y) del frame padre
Box = {
   x = nil,
   y = nil,
   w = nil, 
   h = nil
}

Box.__index = Box --Crea clase
function Box:new(x,y,w,h)
   local self = setmetatable({}, Box)
   self.x = x
   self.y = y
   self.w = w 
   self.h = h
   return self
end

--Muestra las coordenadas propias en pantalla para mayor comodidad
--[[   Mala idea xq su pos está atada a la de su personaje y no referencio eso por ahora
function Box:mostrarCoords()

   return
end
]]
----------------------- FRAME: Tiene imagen y hasta 3 boxes adentro

Frame = {
      name = '', --nombre . No se si se usa
      imagen = nil,
      hitbox = nil,
      hurtbox = nil,
      collisionbox = nil
      --shape = 'rect' por cosas con otro tipo de formas. Por ahora no usado 
      }

Frame.__index = Frame --Crea clase
function Frame:new(imagen)
   local self = setmetatable({}, Frame)
    self.name = name or ''
    self.imagen = imagen
    self.hitbox = nil
    self.hurtbox = nil
    self.collisionbox = nil
   return self
end

----------------------- SPRITES: Tiene Frames


--Como arriba, pero hace más calculos para conseguir las coordenadas de los hitboxes
function cargarFramesYHitboxes(carpeta)


   carpeta = 'img/'.. carpeta
   print('Leyendo sprites en ' .. carpeta)

   --TRIM: SI la carpeta es knight/, voy a hacer un trim. OJO CON OLVIDAR ESO
   --local trim = false --Esto lo agregué para los sprites de PJE: Recorta todo el espacio vacío y devuelve solo lo "minimo" indispensable
   --if string.find (carpeta, 'knight/') then trim = true end
   --Esta manera no es robusta asi que la desactivo


   imagenes = loadSprites(carpeta) --consigo las imagenes. Acá estan todas, los frames propiamente, hit, hurt y collision boxes. Cada uno con un tag en el nombre
   frames = {}
   local hbox_imgs = {}
   local hurtbox_imgs = {}
   local collisions_imgs = {}

   files = love.filesystem.getDirectoryItems(carpeta)

   for i, filename in ipairs(files) do
      local img = love.graphics.newImage(carpeta .. filename) --Esto se puede dibujar en pantalla
      local imgData = love.image.newImageData(carpeta .. filename) --No se puede dibujar, pero puedo acceder a los pixeles. con el otro no

      if     string.find (filename, 'hitbox') then table.insert(hbox_imgs,imgData) --Si el file tiene info de hitbox paso
         elseif string.find (filename, 'hurtbox') then table.insert(hurtbox_imgs,imgData)
         elseif string.find (filename, 'coll') then table.insert(collisions_imgs,imgData)
         else  table.insert(frames, Frame:new(img)); frames[#frames].name = filename
      end
   end
    
   --Recorro los hitbox y los creo si existen
    for i, frame in ipairs(frames) do 
      
      print(frame.name)

      local x, y,w, h = getXYWH(hbox_imgs[i])
      if w and h then frame.hitbox = Box:new(x,y,w,h) ; print('Hitbox aca') end

      x,y,w,h = getXYWH(hurtbox_imgs[i])
      if w and h then frame.hurtbox = Box:new(x,y,w,h) ; print('Hurtbox aca') end

      x,y,w,h = getXYWH(collisions_imgs[i])
      if w and h then frame.collisionbox = Box:new(x,y,w,h) ; print('Collisionbox aca') end

    end

    print( carpeta .. ' leida')

   return frames
end



--Recibe un png idealmente vacío salvo por un rectangulo, y devuelve posicion de x,y,w y h de ese rect
-- Lo que hace es encontrar el menor rectangulo posible que tiene pixeles de la imagen, ignorando espacios vacios.
-- Util para recortar bordes vacios en sprites
function getXYWH(imgdata)

   img = imgdata --renombre comodo

   if not img then return nil,nil, nil, nil end -- No hay hitbox

    local W = img:getWidth()
    local H = img:getHeight()

    --local x, y, w, h = W, H, 0, 0 
    local x, y, x2,y2 = W,H,0, 0
    local umbral = 0.5 --umbral de "energia" para ver si un pixel está encendido

    local step = 2
    --Primero busco los vertices sup izq e inf der
    for c = 0, W-1, step do -- columna
      for f = 0, H-1, step do -- fila
        local r, g, b, a = img:getPixel(c, f)  --acá si indexa de 0 a N-1 ....
        --print('x:',c,' y :', f ,': ' , r,g,b,a)
         --if(r^2 + g^2 + b^2  > umbral) then
            if(a > umbral) then --Acá estoy dentro del hitbox
             x = math.min(x, c)
             y = math.min(y, f)
             x2 = math.max(x2, c)
             y2 = math.max(y2, f)
          end
         end
      end

   --print(x,y,x2,y2)
   --Y ahora calculo el ancho y alto (se... carisimo... dos pasadas. Pero bueno)

    w = x2-x
    h = y2-y

   --print(x,y,w,h)
   return x,y,w,h
end

--Dibuja un objeto love.image con las coordenadas y tamaño que le pases
function drawImage(img, x, y, width, height, offsetX, rotation, alpha) --Como esto no es básico... dios
   local w = img:getWidth()
   local h = img:getHeight()
   love.graphics.draw(img, x, y, rotation, width/w, height/h, offsetX, 0) --fondo
end


function drawImage2(img, x, y, scale)
   love.graphics.draw(img, x, y, 0, scale, scale, 0 , 0)
end

function drawImage2Izq(img, x, y, scale)
   love.graphics.draw(img, x, y, 0, -scale, scale, img:getWidth(), 0 )
end
--Ojo con esto que me rompió el coco más de un dia... para hacer el flip, el parametro Offset se aplica ANTES del SCALE


--Recorta todos los sprites de un objeto guardandose para que empiecen en (x,y) y con dimensiones w,h
--Obviamente hecho para los sprites de knight nada mas
--La idea es recortar el espacio sobrante de los frames pero que sea igual en todos

--Unused
function trimSprites(objeto, x,y, w, h)

   local trimmedImageData = love.image.newImageData(w, h)

   for i, estado in pairs(objeto.estados) do
      for frame in pairs(estado.frames) do

          -- Copy pixels from the original image
          trimmedImageData:paste(frame.imagen, 0, 0, x, y, w, h)

         -- Reemplazo el frame grande con el chico
          frame.imagen = love.graphics.newImage(trimmedImageData)

         --This saves the trimmed image as "trimmed_output.png" in the game directory.
          --trimmedImageData:encode("png", "trimmed_output.png")
       end
    end
end
 
