require 'tadb'
require_relative './Columna'
# agregar mensaje id :D
module Orm
  def get_table
    self.class.name.downcase
  end

  def get_columns
    self.class.columns || []
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
    get_columns.each do |columna|
      atributo = columna.atributo
      valor = self.send(atributo)
      columna.validar(self.class, valor)
    end
  end

  def save!
    hash = {}
    validate!
    get_columns.each do |columna|
      valor = self.send(columna.atributo)
      if valor.nil?
        valor = columna.valor_default
      end
      if !valor.nil? && !valor.is_a?(Array)
        valor_a_guardar = valor
        if columna.es_persistible
          if valor.id.nil?
            valor.save!
          end
          valor_a_guardar = valor.id
        end
        hash[columna.atributo] = valor_a_guardar
      end
    end
    @id = TADB::DB.table(get_table).insert(hash)
    principal_table = get_table
    get_columns.each do |columna|
      valor = self.send(columna.atributo)
      if valor.nil?
        valor = columna.valor_default
      end
      if valor.is_a? Array
        valor.each do |has_many_valor|
          id = has_many_valor.save!
          secondary_table = columna.obtener_tabla
          has_many_hash = {"id_#{principal_table}": @id, "id_#{secondary_table}": id}
          TADB::DB.table("#{principal_table}_#{secondary_table}").insert(has_many_hash)
        end
      end
      return @id
    end
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

    def has_one(type, named:, **params_opcionales)
      columnas_de_superclase = []

      if self.respond_to?(:superclass)
        tiene_superclase_persistible = self.superclass.respond_to?(:has_one)
        if tiene_superclase_persistible
          columnas_de_superclase = (self.superclass.columns) ? self.superclass.columns : []
        end
      end

      modulos_persistibles_incluidos = included_modules.select do |x|
        x.respond_to?(:has_one) ## distinguir pot orm
      end
      columnas_de_todos = modulos_persistibles_incluidos.flat_map { |modulo| modulo.columns }
      # NTH :  revisar
      unless @columns
        @columns = columnas_de_todos + columnas_de_superclase
      end
      # TODO: hace un test sobre que este declarado una property en una super clase y se pise en un sub clase
      add_column(Columna.new(clase: type, atributo: named, parametros_opcionales: params_opcionales))
      add_column(Columna.new(clase: String, atributo: :id))
      attr_accessor :id
      attr_accessor named
      valor_default = params_opcionales[:default]
      if valor_default
        self.define_method(:initialize) do
          self.send(named.to_s + '=', valor_default)
        end
      end
    end

    def has_many(type, named:, **parametros_opcionales)
      handle_columns
      # TODO cambiar al metodo por add_column pero antes generar el test correspondiente
      # TODO : preguntar que pasa si un has_many pisa a un has_one, deberia ser posible ?
      # nice to have :D
      add_column(Columna.new(clase: type, atributo: named, has_many: true, parametros_opcionales: parametros_opcionales))
      add_column(Columna.new(clase: String, atributo: :id))
      attr_accessor :id
      attr_accessor named

      valor_default = parametros_opcionales[:default]
      if valor_default
        unless valor_default.is_a? Array
          raise "El valor del default no es valido"
        end
        self.define_method(:initialize) do
          self.send(named.to_s + '=', valor_default)
        end
      else
        self.define_method(:initialize) do
          self.send(named.to_s + '=', [])
        end
      end
    end

    def add_column(nueva_columna)
      handle_columns
      hubo_reemplazo = false
      @columns = @columns.map { |columna|
        if columna.atributo == nueva_columna.atributo
          hubo_reemplazo = true
          nueva_columna
        else
          columna
        end
      }
      unless hubo_reemplazo
        @columns.push(nueva_columna)
      end
    end

    def handle_columns
      unless @columns
        @columns = []
      end
    end

    def find_by_id(id)
      TADB::DB.table(self.name.downcase)
          .entries
          .select { |entry| entry[:id] === id }
          .first
    end

    def obtener_objeto_de_dominio(id, objeto_db_param = false) # TODO: pensar una mejor firma para este metodo
      objeto_db = objeto_db_param || self.find_by_id(id)
      objeto = self.new
      popular_objeto(objeto, objeto_db, @columns)
      objeto
    end

    def popular_objeto(objeto, objeto_db, columnas)
      columnas.each { |columna|
        valor = objeto_db[columna.atributo]
        if columna.es_persistible
          id = valor
          valor = columna.clase.obtener_objeto_de_dominio(id)
        end
        objeto.instance_variable_set("@#{columna.atributo}", valor)
      }
    end

    def get_table
      self.name.downcase
    end

    def all_instances
      all_instances_descendientes = (@descendientes) ?
                                        @descendientes.flat_map do |descendiente|
                                          descendiente.all_instances
                                        end : []
      all_instances_clase = TADB::DB.table(get_table).entries.map { |entry|
        self.obtener_objeto_de_dominio(entry[:id], entry)
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