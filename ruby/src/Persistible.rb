require_relative './Columna/HasManyColumna'
require_relative './Columna/HasOneColumna'
require_relative './Tabla'
# TODO : hacer metodos mas cohesivos y empezar a delegar
SEARCH_BY_PREFIX = "search_by_"
module Persistible

  def get_table
    clase.get_table
  end

  def check_id
    if self.id.nil?
      raise "Este objeto no esta persistido"
    end
  end

  def clase
    self.class
  end

  def save!
    @id = clase.save!(self)
  end

  def resfresh!
    check_id
    clase.refresh!(self)
  end

  def forget!
    check_id
    clase.forget!(id)
    self.id = nil
  end


  module MetodosDeClase
    attr_accessor :columns, :descendientes

    def included(sub_clase)
      self.agregar_descendiente(sub_clase)
    end

    def inherited(sub_clase)
      self.agregar_descendiente(sub_clase)
    end

    def agregar_descendiente(descendiente)
      self.descendientes.push(descendiente)
    end

    def es_persistible(valor)
      valor.ancestors.include?(Persistible)
    end

    def has_one(type, named:, **params_opcionales)
      columna = HasOneColumna.new(clase: type, atributo: named, parametros_opcionales: params_opcionales)
      definir_columna(columna)
    end

    # TODO : preguntar que pasa si un has_many pisa a un has_one, deberia ser posible ? nice to have :D
    def has_many(type, named:, **parametros_opcionales)
      columna = HasManyColumna.new(clase: type, atributo: named, parametros_opcionales: parametros_opcionales)
      columna.validar_valor_default
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

    def definir_columna(columna)
      columnas_de_superclase = get_columnas_super_clase
      columnas_de_todos = get_columna_de_todos
      @columns = self.columns.merge(columnas_de_todos.merge(columnas_de_superclase))
      self.columns[columna.atributo] = columna
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
      unless @descendientes
        @descendientes = []
      end
      @descendientes
    end

    def obtener_objeto_de_dominio(objeto_db)
      objeto = self.new
      popular_objeto(objeto, objeto_db)
      objeto
    end

    def refresh!(objeto)
      objeto_db = Tabla.find_by_id(get_table, objeto.id)
      popular_objeto(objeto, objeto_db)
    end

    def save!(objeto)
      self.validate!(objeto)
      id = Tabla.guardar_atributos_simples(columns, objeto)
      Tabla.guardar_atributos_compuestos(columns, objeto, id)
      id
    end

    def forget!(id)
      Tabla.borrar(get_table, id)
    end

    def validate!(objeto)
      columns.each_value do |columna|
        atributo = columna.atributo
        valor = objeto.send(atributo)
        columna.validar(self, valor)
      end
    end

    def popular_objeto(objeto, objeto_db)
      self.columns.each_value { |columna|
        valor = objeto_db[columna.atributo]
        if columna.es_persistible
          id = valor
          valor = columna.clase.obtener_objeto_de_dominio(Tabla.find_by_id(columna.clase.get_table, id))
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
      all_instances_clase = Tabla.all_instances(get_table).map { |entry|
        self.obtener_objeto_de_dominio(entry)
      }
      all_instances_clase + all_instances_descendientes
    end

    def method_missing(symbol, *args, &block)
      nombre_mensaje = symbol.to_s
      if nombre_mensaje.start_with?(SEARCH_BY_PREFIX)
        mensaje = nombre_mensaje.gsub(SEARCH_BY_PREFIX, '').to_sym
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

    def respond_to_missing?(sym, priv = false)
      sym.to_s.start_with?(SEARCH_BY_PREFIX)
    end

    def validar_su_objeto_si_responde_a(entidad, mensaje)
      unless entidad.method_defined?(mensaje)
        raise "No todos entienden #{mensaje} !"
      end
    end
  end

  def self.included(base)
    base.extend(MetodosDeClase)
    base.columns[:id] = Columna.new(clase: String, atributo: :id)
    base.send(:attr_accessor, :id)
  end

end