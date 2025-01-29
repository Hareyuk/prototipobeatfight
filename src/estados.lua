--Una clase Estado guarda los sprites del estado actual y parámetros relacionados.
--Cada instancia de objeto tiene un array de estados y un metodo para asignar estado

Estado = {
         frames = nil,     --Array de frames. Un frame guarda imagen, hitbox, hurtbox y collision box
         currentFrame_t = 1, --timer para pasar de frames.
         currentFrame_i = 1, --indice al frame actual.  Es floor() del timer. Por comodidad lo doy como una variable aparte. Podría ser un método.
         name = '', --id para encontrarlo o acceder a él desde un personaje
         rate = 1, --velocidad a la que cicla los frames
         update_function = nil, -- funcion a ser llamada cada frame durante este estado. Algunos estados piden hacer cosas especiales, eso se asigna acá. Por ej: Dash del personaje
         init_function = nil, --function a ser llamada al entrar a este estado
         parent = nil, --el objeto padre de este estado. Unused
         nframes = 0 -- Cuantos frames hay en frames. Si no hay orientacion, es simplemente #self.frames 
      }

--Expandir luego acá con los hitboxes y demás

Estado.__index = Estado --Crea clase

function nada() end --para no pensar mucho cuando tengo que llamar a init y update de estado

--Constructor de objeto
function Estado:new(name, path_frames, init_function, update_function, orientacion, parent)
    local self = setmetatable({}, Estado)
    self.name = name or ''
    --self.frames = loadSprites(path_frames)  acá los frames eran solo imagenes. Viejo
   

    --Asigno frames segun si el objeto tiene orientacion o no. 
    --Ojo: no mezclar frames con y sin orientacion en un solo objeto porque se rompe esta logica
    if orientacion then 
       self.frames = {}
       self.frames[orientacion] = cargarFramesYHitboxes(path_frames) --Acá los frames son instancias de Frame. Ademas de la imagen, tienen coordenadas de los hitboxes
       self.nframes = #(self.frames[orientacion]) 
    else
       self.frames = cargarFramesYHitboxes(path_frames) --Acá los frames son instancias de Frame. Ademas de la imagen, tienen coordenadas de los hitboxes
       self.nframes = #self.frames
   end 
   
    self.init_function = init_function or nada
    self.update_function = update_function or nada
    self.parent = parent
  return self
end


--Podria solucionar esto MUY facil en una sola linea arriba, con un self.frames = self.frames or {}
--Pero prefiero mantener la coherencia en español del asunto
function Estado:addOrientacion(path_frames, orientacion)
    self.frames[orientacion] = cargarFramesYHitboxes(path_frames)
end


function Estado:ciclarFrames(dt)

   self.currentFrame_t = (self.currentFrame_t + dt*self.rate) % self.nframes --incremento tiempo , y wrap si me paso 
   self.currentFrame_i = math.floor(self.currentFrame_t) + 1 --en lua se indexa desde 1
end



function Estado:getFrameActual(orientacion)

    if orientacion then return self.frames[orientacion][self.currentFrame_i] end
   --else, no tiene orientacion:
   return self.frames[self.currentFrame_i] --Ojo que es un objeto y no una imagen.
end
