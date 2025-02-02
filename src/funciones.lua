--Funciones generales

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end



--Ver si elem está en la tabla (mira IMAGENES)
function estaEn(tabla, elem)
 for _, value in pairs(tabla) do
    if value == elem then
      return true
    end
  end
  return false
end

function esClave(clave, tabla)
 for key, _ in pairs(tabla) do
    if key == clave then
      return true
    end
  end
  return false
end


function chequearColision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end


--Norma 2 al cuadrado
function dist22(obj1, obj2)
    return (obj1.x - obj2.x)^2 + (obj1.y - obj2.y)^2
end     

  --Norma 2 
function dist2(obj1, obj2)
    return math.sqrt((obj1.x - obj2.x)^2 + (obj1.y - obj2.y)^2)
end

  --Norma 2 escalada por las dimensiones de la pantalla 
function dist2_scaled(obj1, obj2)
    return math.sqrt( ((obj1.x - obj2.x)/SCREEN_WIDTH)^2 + ((obj1.y - obj2.y)/SCREEN_HEIGHT)^2)
end



  --Norma 1 escalada por las dimensiones de la pantalla 
function dist1_scaled(obj1, obj2)
    return math.abs(obj1.x - obj2.x)/SCREEN_WIDTH + math.abs(obj1.y - obj2.y)/SCREEN_HEIGHT
end


--Si   |val| < eps, devuelve 0. Sino, deja val
function math.reduceto0(val, eps)
  if(math.abs(val) < eps) then return 0 else return val end
end