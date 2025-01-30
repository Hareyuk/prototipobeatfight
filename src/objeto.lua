--Modulo general de objetos. Todo lo que se muestre en pantalla con sprites es un objeto

--id = 0 -- Le asigna un id de objeto a todos los objetos. Util por si despues se quiere debugear

Objeto = {x = 0, y  = 0,
         velx = 0, vely = 0,
         accx = 0, accy = 0,
         prev_x = 0, prev_y = 0, --para updatear el movimiento
         scale = 1,
         estados = nil, --array de Estados
         estado = nil,  --estado actual. Una instancia de Estado, referencia a un elemento de self.estados
         orientacion = nil,  
         name = '', -- Nombre propio. Que objeto es
         debug = false, --Para cosas como mostrar su ubicacion, valor de atributos, etc
         w = nil , h = nil -- Dimensiones del objeto. En general es cuando está en "idle"
      }

Objeto.__index = Objeto --Crea clase

--[[
   La logica de orientaciones es asi:
   Si un objeto no tiene orientacion, entonces su estado tiene array de frames y se llama como 
      self.estado.frames[i]
   Ahora, si un objeto tiene orientacion, se llaman a los frames como 
      self.estado.frames[self.orientacion][i]
   


]]


--[[ Por si se quiere optimizar mas
Objeto_idle = {
   x = 0, y = 0,
   scale = 1,
   currentFrame_t = 1,
   currentFrame =
}
]]


--Constructor de objeto
function Objeto:new(name)
    local self = setmetatable({}, Objeto)
    self.name = name or ''
    self.estados = {}

    print('Objeto '.. name .. ' creado')
  return self
end

--Asignacion de estados
require "estados"
function Objeto:addEstado(nombre, path_sprites, init_function, update_function, orientacion)
   self.estados[nombre] = Estado:new(nombre, path_sprites, init_function, update_function, orientacion)

   self.estado = self.estados[nombre] --Asigno el estado actual como este. 
                                       --Esto es mas que nada para que funcione lo de abajo.

   -- Si no tiene dimensiones, se las asigno
   self.orientacion = orientacion
   local w, h = self:getWH()
   self.w = self.w or w
   self.h = self.h or h   

   --[[
   if(DEBUG) then
      for i, estado in pairs(self.estados) do
         print('Estados de ' .. self.name .. ' : '..  estado.name)
      end
   end
   ]]

end

function Objeto:addOrientacionEstado(nombre, path_sprites, orientacion)
   self.estados[nombre]:addOrientacion(path_sprites, orientacion)
end

--Se fija si el nombre del estado actual es alguno de los de la lista
--Devuelve un bool
function Objeto:estaEnEstado(lista)
   return estaEn(lista, self.estado.name)
end


--Recibe un array de frames para ya dibujar ese estado actual.
--function Objeto:setSprites(frames, framei = 1, rate = self.rate)

function Objeto:setEstado(estadoName, params, framei, rate)

   self.estado = self.estados[estadoName]
   self.estado.rate = rate  or self.rate -- rate de ciclado de sprites.
   self.estado.currentFrame_t = 0 -- timer
   self.estado.init_function(self) --llamo a la funcion de inicializacion de estado si es que tiene

end


function Objeto:updateEstado(dt)
   self.estado.update_function(self, dt) --si el estado actual hace algo especial, se pide acá
end


-- Actualiza x e y segun vel, acc, etc
function Objeto:updatePosition(dt) 

   self.prev_x, self.prev_y = self.x, self.y

   self.x = self.x + self.velx*dt
   self.y = self.y + self.vely*dt

   self.velx = self.velx + self.accx*dt
   self.vely = self.vely + self.accy*dt

end

--Avanza los frames segun haga falta
function Objeto:ciclarFrames(dt)
   self.estado:ciclarFrames(dt, self.orientacion)
end

--Lo hago asi en vez de llamar uno por uno en love.update()
--para que otros objetos puedan overridear esta funcion agregandole mas cosas si necesitan
function Objeto:update(dt)
   --print('Haciendo update de ' .. self.name, 'estado '.. self.estado.name)
   self:updatePosition(dt)
   self:updateEstado(dt)
   self:ciclarFrames(dt)



end



function Objeto:mostrarBox(boxtype) --muestra uno de los tres tipos de hitbox, con su color y todo

   local frame = self:getFrameActual()
   local box = frame[boxtype] --esto es como hacer frame.hurtbox y asi. Sintaxis rota

   if not box then return end --si no hay hitbox aca se acabo la joda

   love.graphics.push('all')

   local alpha = 0.8
   if(boxtype == 'hitbox') then love.graphics.setColor(1,0,0, alpha)
   elseif (boxtype == 'hurtbox') then love.graphics.setColor(0,0,1, alpha)
   elseif (boxtype == 'collisionbox') then  love.graphics.setColor(0,1,0, alpha)
   end

   --print(box.x, box.y, box.w, box.h)
   --print(self.x + box.x*self.scale, self.y + box.y*self.scale, box.w*self.scale, box.h*self.scale)

   love.graphics.rectangle('fill', self.x + box.x*self.scale
                                 , self.y + box.y*self.scale
                                 , box.w*self.scale
                                 , box.h*self.scale) 
   
   love.graphics.pop()
end


function Objeto:mostrarHitbox()
   self:mostrarBox('hitbox')
end

function Objeto:mostrarHurtbox()
   self:mostrarBox('hurtbox')
end

function Objeto:mostrarCollisionbox()
    self:mostrarBox('collisionbox')
end

function Objeto:setScale(s)
   self.scale = s
   self.w, self.h = self:getWH()
end

-- Todo : Calcular si el personaje aparece en pantalla o no antes de dibujar (ej "es visible")
function Objeto:drawFrame()

   --print('Dibujando '.. self.name ..' | frame de estado ' .. self.estado.name)
   if(not self:esVisible()) then return end 

   love.graphics.push('all')

   --love.graphics.scale(self.scale)

   local sp = self:getFrameActual().imagen --sprite a dibujar, es una imagen



   --El pje mira hacia la izquierda
   if self.orientacion == 'Izquierda' then
      --drawImage(sp, self.x, self.y, -self.w, self.h, self.w,0)
      drawImage2Izq(sp, self.x, self.y, self.scale)
   --El pje mira hacia la derecha, arriba o  abajo
   --Nota: Todo esto se podría optimizar, ya se sabe, usando un unico digito para la orientacion y eso
   else 
      --drawImage(sp, self.x, self.y, self.w, self.h, 0,0)
      drawImage2(sp, self.x, self.y, self.scale, 0)
   end

   if(DEBUG) then
      self:mostrarCoords()
      self:mostrarBordes()
      self:mostrarCentro()


      self:mostrarHurtbox()
      self:mostrarCollisionbox()
      self:mostrarHitbox()
      
   end

   love.graphics.pop()

end


function Objeto:esVisible()


   return true
end

--Muestra las coordenadas propias en pantalla para mayor comodidad
--Y tambien el nombre de estado arriba del pje
function Objeto:mostrarCoords()


   love.graphics.push('all')

   --love.graphics.translate(self.x, self.y)
   --love.graphics.scale(self.scale)

   love.graphics.setFont(fontDebug)

   local MOSTRAR_EN_PJE = true -- Las muestra en la misma posicion del personaje

   local w, h = self:getWH()

   local x_str = string.format("%.2f", self.x ) 
   local y_str = string.format("%.2f", self.y) 

   if MOSTRAR_EN_PJE then 

      local coords = "x: " .. x_str .. "\ny: " .. y_str
      local color_rojo = {235/255,20/255,20/255} --rojo
      local limite_pix = 350 --limite antes del wrap
      local pies = love.math.newTransform(self.x, self.y + h) -- --se muestra a los pies
      love.graphics.printf( {color_rojo,coords} , pies, limite_pix, "left" )  

      local cabeza = love.math.newTransform(self.x, self.y*0.95) -- --se muestra a los pies
      local color_verde = {10/255,220/255,20/255} --no rojo

      local ori = self.orientacion or '' --Si tiene orientacion tam la muestro
      love.graphics.printf( {color_verde,self.estado.name .. ' | ' .. ori} , cabeza, limite_pix, "left" )  

   else --Las muestra abajo en un lugar fijo de la pantalla

   end

   --local hbox = self.estado:getFrameActual().hitbox 
   --if hbox then hbox:mostrarCoords() end

   love.graphics.pop()

   return
end

--Muestra los bordes del frame actual 
function Objeto:mostrarBordes()

   love.graphics.rectangle('line', self.x
                                 , self.y
                                 , self.w
                                 , self.h) 
   return
end

function Objeto:mostrarCentro()

   love.graphics.circle('fill', self.x + self.w/2
                                 , self.y + self.h/2
                                 , self.w/20) 
   return   
end



--Devuelve el objeto Frame actual
function Objeto:getFrameActual()
   return self.estado:getFrameActual(self.orientacion)
end 

--Devuelve el ancho y altura en pantalla del frame actual. Ya incorpora el scale
function Objeto:getWH()
   return self:getFrameActual().imagen:getWidth() * self.scale, self:getFrameActual().imagen:getHeight() * self.scale
end


-------------------------------------- DETECCION DE COLISIONES -- LOGICA


--La idea es: Un objeto con frame de hit se fija si está chocando a otro objeto con frame de hurt
--TODO: sacar los scales y chau. Es un quilombo trabajar siempre con eso
--Si está hiteando, envía la información del hit a ambos objetos
function Objeto:haySolapamiento(obj1, box1, obj2, box2)
      

   return chequearColision(box1.x*obj1.scale + obj1.x,
                           box1.y*obj1.scale + obj1.y,
                           box1.w*obj1.scale,
                           box1.h*obj1.scale,
                           box2.x*obj2.scale + obj2.x,
                           box2.y*obj2.scale + obj2.y,
                           box2.w*obj2.scale,
                           box2.y*obj2.scale
                           )

end

function Objeto:checkHit(otroObjeto)
   
   --print('Chequeando Hit de ' .. self.name .. ' a ' .. otroObjeto.name)

   --print('Loading hurtbox de ' .. otroObjeto.name)
   local htbox = self:getFrameActual().hitbox 

  ---print('Loading hitbox de ' .. self.name)
   local hurtbox = otroObjeto:getFrameActual().hurtbox

   if not htbox or not hurtbox then return end

   if not Objeto:haySolapamiento(self, htbox, otroObjeto, hurtbox) then return end

   -- Procesar abajo lo que pasa si hay hit
   
   print('Ataque de ' ..self.name .. ' a '..otroObjeto.name)

   otroObjeto:setEstado('HURT1')

end


function Objeto:checkMvtColl(otroObjeto)

   --print('Chequeando colision de ' .. self.name .. ' a ' .. otroObjeto.name)

   --print('Loading collision box de ' .. self.name)
   local collbox1 = self:getFrameActual().collisionbox 


   --print('Loading collision box de ' .. otroObjeto.name)
   local collbox2 = otroObjeto:getFrameActual().collisionbox


   if not collbox1 or not collbox2 then return end

  -- print('Ambos tienen collbox. Calculando colision:')

   if not Objeto:haySolapamiento(self, collbox1, otroObjeto, collbox2) then return end

   --Else: Sí hay solapamiento. Les digo a los dos objetos que no pueden moverse
   --Todo: Luego hay condiciones como "está en estado idle" o cosas así
   self:noMover()
   otroObjeto:noMover()

   print('Solapamiento de ' ..self.name .. ' a '..otroObjeto.name .. ' en t = ' ..  love.timer.getTime())

end

function Objeto:noMover()
   self.x, self.y = self.prev_x, self.prev_y
end


--Funcion para decidir en que orden se grafican las cosas. Decido que se grafique primero lo que está "más abajo".
--Como se determina eso, bueno, por ahora lo decidí así
--Asi grafica ultimo el que está más abajo (en primer plano el que tiene mayor coord y en el pie) 
function compararSegunY(obj1, obj2)

   --Mas rapido: Usa las dimensiones preguardadas
    return obj1.h*obj1.scale + obj1.y < obj2.h*obj2.scale + obj2.y


--   Mas preciso: Calcula la altura y ancho en cada frame.
--   return obj1:getFrameActual().imagen:getHeight()*obj1.scale + obj1.y < obj2:getFrameActual().imagen:getHeight()*obj2.scale + obj2.y

end