def find_by_id(table, id)
  TADB::DB.table(table)
      .entries
      .select { |entry| entry[:id] === id }
      .first
end

def get_relaciones(relacion, symbol_id, id)
  TADB::DB.table(relacion).entries.select do |entry|
    entry[symbol_id] == id
  end
end

class Material
  include Persistible
  has_one String, named: :peso
end
class Herramienta
  include Persistible
  has_one Material, named: :material
end
class Obrero
  include Persistible
  has_one Herramienta, named: :herramienta
  has_one String, named: :nombre
end