require 'tadb'
require_relative './Columna/HasManyColumna'
require_relative './Columna/HasOneColumna'
require_relative './Tabla'
# TODO : hacer metodos mas cohesivos y empezar a delegar
module Persistible
  def get_table
    self.class.get_table
  end

  def get_columns
    self.class.columns
  end

  def popular_objeto(objeto, objeto_db)
    self.class.popular_objeto(objeto, objeto_db, get_columns)
  end

  def check_id
    if self.id.nil?
      raise "Este objeto no esta persistido"
    end
  end

  def validate!
    get_columns.each_value do |columna|
      atributo = columna.atributo
      valor = self.send(atributo)
      columna.validar(self.class, valor)
    end
  end

  def save!
    validate!
    columnas = get_columns
    @id = Tabla.guardar_atributos_simples(columnas, self)
    Tabla.guardar_atributos_compuestos(columnas, self, @id)
    @id
  end

  def resfresh!
    check_id
    objeto_db = self.class.find_by_id(self.id)
    popular_objeto(self, objeto_db)
  end

  def forget!
    check_id
    TADB::DB.table(get_table).delete(self.id)
    self.id = nil
  end


  module ClassMethods
    # TODO :  evaluar la posibilidad de cambiar columnas a un hash
    attr_accessor :columns, :descendientes

    def included(sub_clase)
      self.agregar_descendiente(sub_clase)
    end

    def inherited(sub_clase)
      self.agregar_descendiente(sub_clase)
    end

    def agregar_descendiente(descendiente)
      unless @descendientes
        @descendientes = []
      end
      @descendientes.push(descendiente)
    end

    def es_persistible(valor)
      valor.ancestors.include?(Persistible)
    end

    def has_one(type, named:, **params_opcionales)
      columnas_de_superclase = get_columnas_super_clase
      columnas_de_todos = get_columna_de_todos
      @columns = self.columns.merge(columnas_de_todos.merge(columnas_de_superclase))
      columna = HasOneColumna.new(clase: type, atributo: named, parametros_opcionales: params_opcionales)
      definir_columna(columna)
    end

    def has_many(type, named:, **parametros_opcionales)
      # TODO : preguntar que pasa si un has_many pisa a un has_one, deberia ser posible ? nice to have :D
      valor_default = parametros_opcionales[:default]
      if valor_default
        unless valor_default.is_a? Array
          raise "El valor del default no es valido"
        end
      end
      columnas_de_superclase = get_columnas_super_clase
      columnas_de_todos = get_columna_de_todos
      @columns = self.columns.merge(columnas_de_todos.merge(columnas_de_superclase))
      columna = HasManyColumna.new(clase: type, atributo: named, parametros_opcionales: parametros_opcionales)
      definir_columna(columna)
    end

    def get_columna_de_todos
      modulos_persistibles_incluidos = included_modules.select do |x|
        x.respond_to?(:columns) ## distinguir pot orm
      end
      hash = {}
      modulos_persistibles_incluidos.each do |modulo|
        hash = hash.merge(modulo.columns)
      end
      hash
    end

    def get_columnas_super_clase
      if self.respond_to?(:superclass)
        super_clase = self.superclass
        if es_persistible(super_clase)
          return super_clase.columns
        end
      end
      {}
    end

    # TODO : pensar nombres mas cohesivos y ademas dejar de tener tantos nombres iguales
    def definir_columna(columna)
      self.columns[columna.atributo] = columna
      # TODo: Buscar la manera de no andar declarando todo el tiempo ID, deberia ser solo cuando se lo incluye
      self.columns[:id] = Columna.new(clase: String, atributo: :id)
      attr_accessor :id
      attr_accessor columna.atributo
      self.define_method(:initialize) do
        self.send(columna.atributo.to_s + '=', columna.valor_default)
        super()
      end
    end

    def columns
      unless @columns
        @columns = {}
      end
      @columns
    end

    def descendientes
      # TODO:  hacer un mejor handler con un if
      @descendientes || []
    end

    def find_by_id(id)
      TADB::DB.table(self.name.downcase)
          .entries
          .select { |entry| entry[:id] === id }
          .first
    end

    def obtener_objeto_de_dominio(objeto_db)
      objeto = self.new
      popular_objeto(objeto, objeto_db, self.columns)
      objeto
    end

    def popular_objeto(objeto, objeto_db, columnas)
      columnas.each_value { |columna|
        valor = objeto_db[columna.atributo]
        if columna.es_persistible
          id = valor
          valor = columna.clase.obtener_objeto_de_dominio(columna.clase.find_by_id(id))
        end
        objeto.instance_variable_set("@#{columna.atributo}", valor)
      }
    end

    def get_table
      self.name.downcase
    end

    def all_instances
      all_instances_descendientes = self.descendientes.flat_map do |descendiente|
        descendiente.all_instances
      end
      all_instances_clase = TADB::DB.table(get_table).entries.map { |entry|
        self.obtener_objeto_de_dominio(entry)
      }
      all_instances_clase + all_instances_descendientes
    end

    # TODO: sobrescribir lo que falta para que de true el respond_to
    def method_missing(symbol, *args, &block)
      nombre_mensaje = symbol.to_s
      if nombre_mensaje.start_with?('search_by_')
        mensaje = nombre_mensaje.gsub('search_by_', '').to_sym
        validar_su_objeto_si_responde_a(self, mensaje)
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

    def validar_su_objeto_si_responde_a(entidad, mensaje)
      unless entidad.method_defined?(mensaje)
        raise "No todos entienden #{mensaje} !"
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end