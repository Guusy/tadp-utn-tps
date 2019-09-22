def find_by_id(table, id)
  TADB::DB.table(table)
      .entries
      .select { |entry| entry[:id] === id }
      .first
end

class Material
  include Orm
  has_one String, named: :peso
end
class Herramienta
  include Orm
  has_one Material, named: :material
end
class Obrero
  include Orm
  has_one Herramienta, named: :herramienta
  has_one String, named: :nombre
end