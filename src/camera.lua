--https://gist.github.com/mebens/961685

camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0


function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(self.scaleX, self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end


function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

--No permite salirse de los bordes
function camera:setX(value)
  if self.bounds then
    self.x = math.clamp(value, self.bounds.x1, self.bounds.x2)
  else
    self.x = value
  end
end

--No permie salirse de los bordes
function camera:setY(value)
  if self.bounds then
    self.y = math.clamp(value, self.bounds.y1, self.bounds.y2)
  else
    self.y = value
  end
end


function camera:setPosition(x, y)
  self:setX(x or self.x)
  self:setY(y or self.y)
  --self:move(-SCREEN_WIDTH/2, -SCREEN_HEIGHT/2) --Centro la camara en la pantalla
end

function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end


function camera:getBounds()
  return unpack(self.bounds)
end

function camera:setBounds(x1, y1, x2, y2)
  self.bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end


function camera:mousePosition()
  return love.mouse.getX() * self.scaleX + self.x, love.mouse.getY() * self.scaleY + self.y
end

------------------ A partir de acá son funciones mias

function camera:getWidth()
  return SCREEN_WIDTH / self.scaleX
end

function camera:getHeight()
  return SCREEN_HEIGHT / self.scaleY
end

--CENTRA la camara en (x,y)
function camera:setPositionCentered(x,y)

  --Si quiero que esté CENTRADO en (x,y), tengo que ir hasta ahí, y moverme para atrás una cierta cantidad
  self:setPosition(x-self:getWidth()/2, y - self:getHeight()/2)
end

function camera:mousePositionCentered()
  return love.mouse.getX() * self.scaleX + self.x, love.mouse.getY() * self.scaleY + self.y
end


camera.maxZoomOut = 0.9
camera.maxZoomIn = 1.1
camera.mode = 'center' --Esto es "sintactico". Si la camara está centrada en el punto (0,0), su "x,y" sigue siendo (-algo, -algo)

function camera:followPje(pje)

  pje.isCamLocked = true

  if self.mode == 'top left' then
    camera:setPosition(pje.x, pje.y)
  elseif self.mode == 'center' then
    camera:setPositionCentered(pje.x, pje.y)
  end


end

function camera:followPjes(pjeA, pjeB)

  --Pongo la camara en el punto medio de ambos
  camera:setPositionCentered((pjeA.x + pjeB.x)/2, (pjeA.y + pjeB.y)/2 )

  --Si la distancia 
  local d = dist2_scaled(pjeA, pjeB)
  if d> 0.75 then
    camera:zoom(1 - 0.5*(d-0.75))
  else
    camera:zoom(1)
  end

end

--No acumulativo
function camera:zoom(s)
  s = math.clamp(s, self.maxZoomOut, self.maxZoomIn)
  self:setScale(s,s)
end