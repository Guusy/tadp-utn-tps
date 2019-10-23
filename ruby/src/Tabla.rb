class Tabla
  def self.guardar_atributos_simples(columnas, clase)
    hash = {}
    columnas.each_value do |columna|
      hash = hash.merge(columna.obtener_hash_de(clase))
    end
    TADB::DB.table(clase.get_table).insert(hash)
  end

  def self.guardar_atributos_compuestos(columnas, clase, id)
    columnas.each_value do |columna|
      columna.guardar_relaciones(clase, id)
    end
  end
end