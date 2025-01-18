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


--Dibuja un objeto love.image con las coordenadas y tamaño que le pases
function drawImage(img, x, y, width, height, offsetX, rotation) --Como esto no es básico... dios
   local w = img:getWidth()
   local h = img:getHeight()
   love.graphics.draw(img, x, y, rotation, width/w, height/h, offsetX, 0) --fondo
end




function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end