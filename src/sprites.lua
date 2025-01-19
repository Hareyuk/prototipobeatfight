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
function Box:mostrarCoords()

   love.graphics.setFont(fontDebug)

   local x = string.format("%.2f", self.x)
   local y = string.format("%.2f", self.y)
   local w = string.format("%.2f", self.w)
   local h = string.format("%.2f", self.h)

   local coords = "x: " .. x .. "\ny: " .. y .. "\nw: " .. w .. "\nh: " .. h 
   local color_texto = {235/255,20/255,20/255} --rojo
   local limite_pix = 350 --limite antes del wrap
   local pos = love.math.newTransform(self.x, self.y) -- x e y
   love.graphics.printf( {color_texto,coords} , pos, limite_pix, "left" )  


   return
end

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

   print('Leyendo sprites en ' .. carpeta)

   imagenes = loadSprites(carpeta) --consigo las imagenes. Acá estan todas, los frames propiamente, hit, hurt y collision boxes. Cada uno con un tag en el nombre
   frames = {}
   local hbox_imgs = {}
   local hurtbox_imgs = {}
   local collisions_imgs = {}

   files = love.filesystem.getDirectoryItems(carpeta)

   for i, filename in ipairs(files) do
      local img = love.graphics.newImage(carpeta .. filename)
      local imgData = love.image.newImageData(carpeta .. filename) --lo mismo, pero puedo acceder a los pixeles. con el otro no

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
      if w and h then frame.hurtbox = Box:new(x,y,w,h) ; print('Collisionbox aca') end
    end

    print( carpeta .. ' leida')

   return frames
end



--Recibe un png idealmente vacío salvo por un rectangulo, y devuelve posicion de x,y,w y h de ese rect
function getXYWH(img)

   if not img then return nil,nil, nil, nil end -- No hay hitbox

    local W = img:getWidth()
    local H = img:getHeight()

    local x, y, w, h = W, H, 0, 0 
    local umbral = 0.5 --umbral de "energia" para ver si un pixel está encendido

    for c = 0, W-1, 10 do -- columna
      for f = 0, H-1, 10 do -- fila
        local r, g, b, a = img:getPixel(f, c)  --acá si indexa de 0 a N-1 ....
        --print('x:',c,' y :', f ,': ' , r,g,b,a)
         --if(r^2 + g^2 + b^2  > umbral) then
           if(a > umbral) then
            x = math.min(x, c)
            y = math.min(y, f)
            w = math.max(w, c-x)
            h = math.max(h, f-y)
         end
      end
   end
   print(x,y,w,h)
   return x,y,w,h
end

--Dibuja un objeto love.image con las coordenadas y tamaño que le pases
function drawImage(img, x, y, width, height, offsetX, rotation, alpha) --Como esto no es básico... dios
   local w = img:getWidth()
   local h = img:getHeight()
   love.graphics.draw(img, x, y, rotation, width/w, height/h, offsetX, 0) --fondo
end


