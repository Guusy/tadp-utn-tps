require 'tadb'
class Tabla
  def self.guardar_atributos_simples(columnas, objeto)
    hash = {}
    columnas.each_value do |columna|
      hash = hash.merge(columna.obtener_hash_de(objeto))
    end
    TADB::DB.table(objeto.get_table).insert(hash)
  end

  def self.guardar_atributos_compuestos(columnas, clase, id)
    columnas.each_value do |columna|
      columna.guardar_relaciones(clase, id)
    end
  end

  def self.borrar(tabla, id)
    TADB::DB.table(tabla).delete(id)
  end

  def self.find_by_id(tabla, id)
    return TADB::DB.table(tabla)
        .entries
        .select { |entry| entry[:id] === id }
        .first
  end

  def self.all_instances(tabla)
    TADB::DB.table(tabla).entries
  end
end