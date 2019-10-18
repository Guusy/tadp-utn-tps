require_relative './errores'
class Columna
  attr_accessor :clase, :atributo, :has_many, :parametros_opcionales

  def initialize(clase:, atributo:, has_many: false, parametros_opcionales: {})
    @clase = clase
    @atributo = atributo
    @parametros_opcionales = parametros_opcionales
    @has_many = has_many
  end

  def es_persistible
    self.clase.respond_to?(:has_one)
  end

  def obtener_tabla
    self.clase.get_table
  end

  def valor_default
    parametros_opcionales[:default]
  end

  def validar(clase_contenedora, valor)
    unless atributo === :id
      ejecutar_validate(valor)
      ejecutar_no_blank(valor)
      ejecutar_from_to(valor)
      ejecutar_chequeo_de_tipos(clase_contenedora, valor)
    end
  end

  def intentar_ejecucion(name, action)
    if @parametros_opcionales[name]
      action.call
    end
  end

  def ejecutar_validate(valor)
    validacion = parametros_opcionales[:validate]
    if validacion
      if valor.is_a?(Array)
        valor.each do |hijo|
          unless validacion.call(hijo)
            raise "Algun atributo dentro de #{atributo} no cumple la validacion"
          end
        end
      else
        unless validacion.call(valor)
          raise "El atributo #{atributo} no cumple la validacion"
        end
      end
    end

  end

  def ejecutar_no_blank(valor)
    no_blank = parametros_opcionales[:no_blank]
    if no_blank
      if clase == String
        if valor.empty?
          raise mensaje_error_vacio(atributo)
        end
      end
      if valor.nil?
        raise mensaje_error_vacio(atributo)
      end
    end
  end

  def ejecutar_from_to(valor)
    from = parametros_opcionales[:from]
    to = parametros_opcionales[:to]
    if from
      if valor < from
        raise mensaje_error_menor(atributo, from, valor)
      end
    end
    if to
      if valor > to
        raise mensaje_error_mayor(atributo, to, valor)
      end
    end
  end

  def ejecutar_chequeo_de_tipos(clase_contenedora, valor)
    if valor
      if has_many
        unless valor.is_a?(Array)
          raise mensaje_error_de_tipos(clase_contenedora, atributo, "Array", valor)
        end
        valor.each do |hijo|
          unless hijo.is_a?(clase)
            raise mensaje_error_de_tipos(clase_contenedora, atributo, clase, hijo.class)
          end
        end
      else
        unless valor.is_a?(clase)
          raise mensaje_error_de_tipos(clase_contenedora, atributo, clase, valor)
        end
      end
    end
  end
end