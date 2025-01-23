--Una clase Estado guarda los sprites del estado actual y parámetros relacionados.
--Cada instancia de objeto tiene un array de estados y un metodo para asignar estado

Estado = {
         frames = nil,     --Array de frames
         currentFrame_t = 1, --timer para pasar de frames.
         currentFrame_i = 1, --indice al frame actual.  Es floor() del timer. Por comodidad lo doy como una variable aparte. Podría ser un método.
         name = '', --id para encontrarlo o accedes a él desde un personaje
         rate = 1, --velocidad a la que cicla los frames
         update_function = nil, -- funcion a ser llamada durante este estado. Algunos estados piden hacer cosas especiales, eso se asigna acá. Por ej: Dash del personaje
         init_function = nil, --function a ser llamada al entrar a este estado
         parent = nil --el objeto padre de este estado
      }

--Expandir luego acá con los hitboxes y demás

Estado.__index = Estado --Crea clase

function nada() end --para no pensar mucho cuando tengo que llamar a init y update de estado

--Constructor de objeto
function Estado:new(name, path_frames, init_function, update_function, parent)
    local self = setmetatable({}, Estado)
    self.name = name or ''
    --self.frames = loadSprites(path_frames)  acá los frames eran solo imagenes. Viejo
    self.frames = cargarFramesYHitboxes(path_frames) --Acá los frames son instancias de Frame. Ademas de la imagen, tienen coordenadas de los hitboxes
    self.init_function = init_function or nada
    self.update_function = update_function or nada
    self.parent = parent
  return self
end


function Estado:ciclarFrames(dt)

   self.currentFrame_t = (self.currentFrame_t + dt*self.rate) % #self.frames --incremento tiempo , y wrap si me paso 
   self.currentFrame_i = math.floor(self.currentFrame_t) + 1 --en lua se indexa desde 1
end



function Estado:getFrameActual()
   return self.frames[self.currentFrame_i] --Ojo que es un objeto y no una imagen.
end
