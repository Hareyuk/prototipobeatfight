--Funcion principal.
--Main file - se tiene que llamar así


-- Importamos las demas clases
require "sprites"--Funciones para abrir sprites y etc
require "pje"    --Personajes jugables
require "stage"  --Escenario
require "objeto" --funciones de objetos con sprites generales
require "camera" --Para fondos scrolleables, zoom en lugares, etc
require "cursor" --Para el mouse bonito
require "fondo"
require "texto"

DEBUG = true -- muestra cosas como coordenadas de personajes, botones apretados y tiempos, etc


--love.load will only get called once when the game is first started (before any other callback). Put code which loads game content and otherwise prepares things.
--doing them here means that they are done once only 
function love.load()

   print("PREPARANDO TODO")

   SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions() -- Dimensiones pantalla (GLOBALES)
   print("DIMENSIONES: ", SCREEN_WIDTH, SCREEN_HEIGHT)

   love.graphics.setDefaultFilter( 'nearest', 'nearest' ) --Algoritmo de interpolacion al agrandar imagenes

   camera:setBounds(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

   Objetos = {} -- Lista de objetos actualmente en el juego. 
                  --Incluye las especializacion como Personaje1 y 2, pero no al Fondo o Escenario

   Fondo:crear()
   cursor:crear()
   pje1 = Personaje:new(1)
   crearTextos()
   crearTextosDebug()

   table.insert(Objetos, pje1)
   table.insert(Objetos, cursor)

   cargarMusica()



   --CONSTANTES DE ESTADO
   READING = 0
   FINISHED = 1

   STATUS = READING


    --OPCIONES DE CAMARA
   camera.CAMERA_SCALE = 1
   camera.cam_Xoff =   pje1.currentFrame:getWidth()*2
   camera.cam_Yoff = pje1.currentFrame:getHeight() *8
   camera:setBounds(0, 0, 0, 0) --En este caso, no dejo que se mueva mucho, porque el fondo ya ocupa toda la pantalla

end







------------------------------------------------------------------------------------

function love.update(dt)

   camera:followPje()

   --fondo:update(dt)

   for _, objeto in ipairs(Objetos) do
      objeto:updatePosition(dt)
      objeto:ciclarFrames(dt)
   end


end
--Called continuously. 'dt' is the amount of seconds since the last time this function was called 
-- num = num + 100 * dt would increment num by 100 per second


------------------------------------------------------------------------------------

--IMPORTANTISIMO: SE REDIBUJA TODO DESDE CERO CADA FRAME. ASí QUE NADA DE OPTIMIZAR EN ESTE FRAMWORK
-- if you call any of the love.graphics.draw outside of this function then it's not going to have any effect.  
function love.draw()

   for _, objeto in ipairs(Objetos) do
      objeto:drawFrame()
   end
   
  --[[
  camera:set() --Start looking through the camera.

   camera:setPosition(pje1.x - WIDTH / 2, pje1.y - HEIGHT / 2)

   --FONDO
   fondo:draw()
   drawSprite(cursor)
   drawSprite(pje1)

   mostrarTexto() 

   camera:unset() -- Stop looking through the camera.
]]


end


------------------------------------------------------------------------------------

--Triggereado al detectar un click.

function love.mousepressed(x, y, button, istouch)
   --if button == 1 then end
   if button == 1 then cursor:cambiarCursor() end
end
--This function is called whenever a mouse button is pressed.  it receives the button and the coordinates of where it was pressed. 

function love.mousereleased(x, y, button, istouch)
end


--Triggereado al detectar un keypress. Hay mas parametros. Trabajarlo aparte del love.keyisdown()
function love.keypressed(key)
   if key == 'return' then avanzarTexto()

   elseif key == 'space' then fondo:cambiarFondo()

   elseif key == 'escape' then love.quit()
   end

   pje1:keypressed(key)

end
--This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. 

function love.keyreleased(key)
end  

------------------------------------------------------------------------------------

function love.focus(f) gameIsPlaying = f end
--This function is called whenever the user clicks off and on the LÖVE window. For instance, if they are playing a windowed game and a user clicks on his Internet browser, the game could be notified and automatically pause the game.



function love.quit()
  print("Thanks for playing! Come back soon!")
end
--This function is called whenever the user clicks the window's close button (often an X). For instance, if the user decides they are done playing, they could click the close button. Then, before it closes, the game can save its state.


--------------------------------------------

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end