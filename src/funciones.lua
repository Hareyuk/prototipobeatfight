--Funciones generales

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end



--Ver si elem está en la tabla
function estaEn(tabla, elem)
 for _, value in pairs(tabla) do
    if value == elem then
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