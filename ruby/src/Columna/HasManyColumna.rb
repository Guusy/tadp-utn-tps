require_relative './Columna'
require_relative '../errores'

class HasManyColumna < Columna
  def valor_default
    valor = parametros_opcionales[:default]
    valor ? valor : []
  end

  def validar_valor_default
    valor_default = parametros_opcionales[:default]
    if valor_default
      unless valor_default.is_a? Array
        raise "El valor del default no es valido"
      end
    end
  end

  def ejecutar_chequeo_de_tipos(clase_contenedora, valor)
    if valor
      unless valor.is_a?(Array)
        raise mensaje_error_de_tipos(clase_contenedora, atributo, "Array", valor)
      end
      valor.each do |hijo|
        unless hijo.is_a?(clase)
          raise mensaje_error_de_tipos(clase_contenedora, atributo, clase, hijo.class)
        end
      end
    end
  end

  def guardar_relaciones(clase,id_principal)
    principal_table = clase.get_table
    valor = clase.send(atributo)
    valor = (valor.nil?) ? valor_default : valor
    valor.each do |has_many_valor|
      id = has_many_valor.save!
      secondary_table = obtener_tabla
      has_many_hash = {"id_#{principal_table}": id_principal, "id_#{secondary_table}": id}
      TADB::DB.table("#{principal_table}_#{secondary_table}").insert(has_many_hash)
    end
  end

end