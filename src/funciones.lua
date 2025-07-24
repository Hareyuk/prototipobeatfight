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



--Funcion para decidir en que orden se grafican las cosas. Decido que se grafique primero lo que está "más abajo".
--Como se determina eso, bueno, por ahora lo decidí así
--Asi grafica ultimo el que está más abajo (en primer plano el que tiene mayor coord y en el pie) 
--Podria poner algun pequeño offset a obj1 para que obj2 tenga que estar cierto umbral mas abajo de el para empezar a estar adelante.
--Como la tabla se recorre en el orden actual me imagino, esto tendria sentido
--Se veia mejor antes del update en que saque h*self.scale, asi que por eso propongo esa
function compararSegunY(obj1, obj2)

  --Los "y" absolutos de los collision boxes se pueden guardar y actualizar frame a frame en el update del objeto en vez de çalcular aca

    --Comparo los pies de cada sprite
    yInferior1, yInferior2 = obj1:bordeInferiorY(), obj2:bordeInferiorY()

    return  yInferior1  < yInferior2 

end