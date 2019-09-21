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
          valor.save!
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
    object_in_db = TADB::DB.table(get_table)
                       .entries
                       .select { |entry| entry[:id] === self.id }
                       .first
    get_columns.each do |column|
      self.instance_variable_set("@#{column[:named]}", object_in_db[column[:named]])
    end
  end

  def forget!
    check_id
    TADB::DB.table(get_table).delete(self.id)
    self.id = nil
  end

  def all_instances
    TADB::DB.table(get_table).entries.map { |entry|
      domain_object = self.class.new
      domain_object.singleton_class.module_eval { attr_accessor :id }
      get_columns.each do |column|
        domain_object.instance_variable_set("@#{column[:named]}", entry[column[:named]])
      end
      domain_object
    }
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

    def method_missing(symbol, *args, &block)
      nombre_mensaje = symbol.to_s
      if nombre_mensaje.start_with?('search_by_')
        mensaje = nombre_mensaje.gsub('search_by_', '').to_sym
        if self.instance_method(mensaje).arity > 0
          raise "No se puede utilizar una propiedad que reciba argumentos"
        end
        objetos_de_dominio = TADB::DB.table(self.name.downcase).entries.map do |entry|
          objeto_de_dominio = self.new
          objeto_de_dominio.singleton_class.module_eval { attr_accessor :id }
          @columns.each do |column|
            if entry[column[:named]]
              objeto_de_dominio.instance_variable_set("@#{column[:named]}", entry[column[:named]])
            end
          end
          objeto_de_dominio
        end
        objetos_de_dominio.select do |objeto_de_dominio|
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