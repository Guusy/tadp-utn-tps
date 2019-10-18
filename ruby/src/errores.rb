def mensaje_error_menor(atributo, valor_esperado, valor_actual)
  "El atributo #{atributo} es menor a #{valor_esperado}, valor actual : #{valor_actual}"
end

def mensaje_error_mayor(atributo, valor_esperado, valor_actual)
  "El atributo #{atributo} es mayor a #{valor_esperado}, valor actual : #{valor_actual}"
end

def mensaje_error_vacio(propiedad)
  "El atributo #{propiedad} esta vacio!"
end

def mensaje_error_de_tipos(clase_base, atributo, clase_esperada, valor)
  "En #{clase_base} el atributo #{atributo} no es un #{clase_esperada}! valor actual : #{valor}"
end