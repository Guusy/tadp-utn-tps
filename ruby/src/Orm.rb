require 'tadb'
module Orm
  def get_table
    self.class.name.downcase
  end

  def get_columns
    self.class.columns || []
  end

  def check_id
    unless self.respond_to?(:id)
      raise "Este objeto no esta persistido"
    end
  end

  def save!
    self.singleton_class.module_eval { attr_accessor :id }
    hash = {}
    get_columns.each do |column|
      symbol = column[:named]
      clase = column[:type]
      valor = self.send(symbol)
      if valor
        valor_a_guardar = valor
        if clase.respond_to?(:has_one)
          unless valor.respond_to?(:id)
            valor.save!
          end
          valor_a_guardar = valor.id
        else
        end
        hash[symbol] = valor_a_guardar
      end
    end
    @id = TADB::DB.table(get_table).insert(hash)
    self.class.add_column({named: :id})
  end

  def resfresh!
    check_id
    object_in_db = self.class.find_by_id(self.id)
    get_columns.each do |column|
      clase = column[:type]
      valor = object_in_db[column[:named]]
      if clase.respond_to?(:has_one)
        id = valor
        objeto_en_db = clase.find_by_id(id)
        valor = clase.new
        clase.columns.each { |columna|
          valor.instance_variable_set("@#{columna[:named]}", objeto_en_db[columna[:named]])
        }
      end
      self.instance_variable_set("@#{column[:named]}", valor)
    end
  end

  def forget!
    check_id
    TADB::DB.table(get_table).delete(self.id)
    self.id = nil
  end


  module ClassMethods
    attr_accessor :columns

    def has_one(type, named:)
      unless @columns
        @columns = []
      end

      @columns.push({'type': type, 'named': named})
      attr_accessor named
    end

    def add_column(column)
      unless @columns
        @columns = []
      end
      @columns.push(column)
    end

    def find_by_id(id)
      TADB::DB.table(self.name.downcase)
          .entries
          .select { |entry| entry[:id] === id }
          .first
    end

    def get_table
      self.name.downcase
    end

    def all_instances
      TADB::DB.table(get_table).entries.map { |entry|
        domain_object = self.new
        domain_object.singleton_class.module_eval { attr_accessor :id }
        domain_object.get_columns.each do |column|
          domain_object.instance_variable_set("@#{column[:named]}", entry[column[:named]])
        end
        domain_object
      }
    end

    def method_missing(symbol, *args, &block)
      nombre_mensaje = symbol.to_s
      if nombre_mensaje.start_with?('search_by_')
        mensaje = nombre_mensaje.gsub('search_by_', '').to_sym
        if self.instance_method(mensaje).arity > 0
          raise "No se puede utilizar una propiedad que reciba argumentos"
        end
        all_instances.select do |objeto_de_dominio|
          objeto_de_dominio.send(mensaje) == args[0]
        end
      else
        super
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end