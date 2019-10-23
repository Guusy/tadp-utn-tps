require_relative './Columna'
require_relative '../errores'

class HasOneColumna < Columna
  def valor_default
    parametros_opcionales[:default]
  end

  def ejecutar_chequeo_de_tipos(clase_contenedora, valor)
    if valor
      unless valor.is_a?(clase)
        raise mensaje_error_de_tipos(clase_contenedora, atributo, clase, valor)
      end
    end
  end
end