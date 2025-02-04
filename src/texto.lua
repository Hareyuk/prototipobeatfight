
color_texto = {} --Definidos en "fondo"

function crearTextosDebug()

   debugfontsize = 12
   fontDebug = love.graphics.newFont("font/fff-forward.regular.ttf", debugfontsize)
end




function crearTextos()

   font = love.graphics.newFont("font/PinyonScript-Regular.ttf", 60)
   love.graphics.setFont(font)

   textos = {}

   for line in love.filesystem.lines("poema.txt") do
     table.insert(textos, line)
   end

end





function avanzarTexto()
   if(textoActual_i < #textos) then 
      textoActual_i = textoActual_i + 1
   else STATUS = FINISHED 
   end

end

function mostrarTexto()
   --love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
   --love.graphics.draw(image, 0, 0, 0, 10, 10) --fondo


   --Color del texto

   if fondo.fondo_i == 3 then --El de burro
      color_texto = {235/255,20/255,220/255} --rosa
   else
      color_texto = {1,1,1} --blanco
   end
   
   texto = textos[textoActual_i]
   pos = love.math.newTransform(200, 50) -- x e y
   limite_pix = 350 --limite antes del wrap

   love.graphics.printf( {color_texto,texto} , pos, limite_pix, "center" )
   --love.graphics.printf( coloredtext, transform, limit, align)
   --love.graphics.print({color_texto,texto}, 300, 50)



end

