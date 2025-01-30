--Funcion principal.
--Main file - se tiene que llamar así


-- Importamos las demas clases
require "funciones" --Funciones generales basicas
require "sprites"--Funciones para abrir sprites y etc
require "estados"--Definicion de clase Estado
require "objeto" --funciones de objetos con sprites generales
require "pje"    --Personajes jugables
require "stage"  --Escenario
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

    --OPCIONES DE CAMARA
   camera:setBounds(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
   --camera:setBounds(0, 0, 0, 0) --En este caso, no dejo que se mueva mucho, porque el fondo ya ocupa toda la pantalla



   objetos = {} -- Lista de objetos actualmente en el juego. 
                  --Incluye las especializacion como Personaje1 y 2, pero no al Fondo o Escenario

   cursor = Cursor:crear()
   pje1 = Personaje:new(1)
   pje2 = Personaje:new(2)

   pje1.isCamLocked = true --No se puede escapar de la camara
   pje2.isCamLocked = false

   columna1 = Columna:new(600, SCREEN_HEIGHT*1.1)
   columna2 = Columna:new(900, SCREEN_HEIGHT*1.1)

   fondo = Fondo:crear() 
   crearTextos()
   crearTextosDebug()

   table.insert(objetos, pje1)
   table.insert(objetos, pje2)
   table.insert(objetos, cursor)
   table.insert(objetos, columna1)
   table.insert(objetos, columna2)

   --cargarMusica()



   --CONSTANTES DE ESTADO
   READING = 0
   FINISHED = 1

   STATUS = READING



end



------------------------------------------------------------------------------------

--Logica de objetos:
--


function love.update(dt)

   require("lovebird").update() --Libreria de debugging. 
   --The console can be accessed by opening the following URL in a web browser: 
   -- http://127.0.0.1:8000

   --fondo:update(dt)


   --Actualizo todos los objetos
   for i_obj, objeto in ipairs(objetos) do

      --Calculo de nuevas posiciones, actualizacion de estados, teclas presionadas, etc
      objeto:update(dt)

       --DETECTOR DE COLISIONES DE HITS
      -- Si el objeto está intentando hitear, veo su hitbox contra todo lo golpeable
      -- Esto es muy pesado por cada frame. La mayoria de los objetos no hacen esto, pero estoy haciendo una busqueda "semi profunda" para darme cuenta.
      -- Es algo que en caso de necesitarse se podría optimizar
      -- Ej, Cada estado podria tener un bool "hits"

      if objeto:getFrameActual().hitbox then
         for _, otroObjeto in ipairs(objetos) do
            if objeto ~= otroObjeto then 
               objeto:checkHit(otroObjeto)
            end 
         end
      end


      --DETECTOR DE COLISIONES DE MOVIMIENTO
      --Si el objeto está intentando moverse, veo su collisionbox contra todos los demas
      if objeto:getFrameActual().collisionbox then
         for j_obj, otroObjeto in ipairs(objetos) do
            if j_obj > i_obj then --Para no repetir los chequeos acá, pido esta condicion 
               objeto:checkMvtColl(otroObjeto) 
            end
         end
      end

   end




end
--Called continuously. 'dt' is the amount of seconds since the last time this function was called 
-- num = num + 100 * dt would increment num by 100 per second


------------------------------------------------------------------------------------

--IMPORTANTISIMO: SE REDIBUJA TODO DESDE CERO CADA FRAME. ASí QUE NADA DE OPTIMIZAR EN ESTE FRAMWORK
-- if you call any of the love.graphics.draw outside of this function then it's not going to have any effect.  

--Logica : Para pje1, Primero se calculan las velocidades en el update
--Luego, en draw se dibuja el sprite
function love.draw()

   camera:set() --Start looking through the camera.
   camera:followPje(pje1)
   --camera:followPjes(pje1, pje2)

   fondo:draw()



   love.graphics.setBackgroundColor( 0.5, 0.5,0.5 , 1 )

   --Por ultimo, una vez que ya calculé y acomodé todo, así sí... dibujo!!   

   table.sort(objetos, compararSegunY)

   for i_obj, objeto in ipairs(objetos) do
      
      objeto:drawFrame()

      objeto:mostrarHurtbox()
      objeto:mostrarCollisionbox()
      objeto:mostrarHitbox()
      

   end
   


   local color_rojo = {235/255,20/255,20/255} --rojo
   local limite_pix = 350 --limite antes del wrap
   local pos = love.math.newTransform(camera.x, camera.y)
   love.graphics.printf( {color_rojo,dist2_scaled(pje1, pje2)} , pos, limite_pix, "left" )  


   --FONDO

   --mostrarTexto() 

   camera:unset() -- Stop looking through the camera.


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
require "keymap" --Acá todas las funciones

------------------------------------------------------------------------------------

function love.focus(f) gameIsPlaying = f end
--This function is called whenever the user clicks off and on the LÖVE window. For instance, if they are playing a windowed game and a user clicks on his Internet browser, the game could be notified and automatically pause the game.



function love.quit()
  print("Thanks for playing! Come back soon!")
end
--This function is called whenever the user clicks the window's close button (often an X). For instance, if the user decides they are done playing, they could click the close button. Then, before it closes, the game can save its state.


--------------------------------------------

