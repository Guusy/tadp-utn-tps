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

  def validate!
    get_columns.each do |columna|
      atributo = columna[:named]
      clase = columna[:type]
      has_many = columna[:has_many]
      no_blank = columna[:no_blank]
      from = columna[:from]
      valor = self.send(atributo)
      if no_blank
        if clase == String
          if valor.empty?
            raise mensaje_error_vacio(atributo)
          end
        end
        if valor.nil?
          raise mensaje_error_vacio(atributo)
        end
      end
      if from
        if valor < from
          raise mensaje_error_menor(atributo, from, valor)
        end
      end
      if valor
        if has_many
          unless valor.is_a?(Array)
            raise mensaje_error_de_tipos(self.class, atributo, "Array", valor)
          end
          valor.each do |hijo|
            unless hijo.is_a?(clase)
              raise mensaje_error_de_tipos(self.class, atributo, clase, hijo.class)
            end
          end
        else
          unless valor.is_a?(clase)
            raise mensaje_error_de_tipos(self.class, atributo, clase, valor)
          end
        end

      end
    end
  end

  def mensaje_error_menor(atributo, valor_esperado, valor_actual)
    "El atributo #{atributo} es menor a #{valor_esperado}, valor actual : #{valor_actual}"
  end

  def mensaje_error_vacio(propiedad)
    "El atributo #{propiedad} esta vacio!"
  end

  def mensaje_error_de_tipos(clase_base, atributo, clase_esperada, valor)
    "En #{clase_base} el atributo #{atributo} no es un #{clase_esperada}! valor actual : #{valor}"
  end

  def save!
    self.singleton_class.module_eval { attr_accessor :id }
    hash = {}
    validate!
    get_columns.each do |column|
      symbol = column[:named]
      clase = column[:type]
      valor = self.send(symbol)
      if !valor.nil? && !valor.is_a?(Array)
        valor_a_guardar = valor
        if clase.respond_to?(:has_one)
          unless valor.respond_to?(:id)
            valor.save!
          end
          valor_a_guardar = valor.id
        end
        hash[symbol] = valor_a_guardar
      end
    end
    @id = TADB::DB.table(get_table).insert(hash)
    self.class.add_column({named: :id})
    principal_table = get_table
    get_columns.each do |columna|
      symbol = columna[:named]
      clase = columna[:type]
      valor = self.send(symbol)
      if valor.is_a? Array
        valor.each do |has_many_valor|
          id = has_many_valor.save!
          secondary_table = clase.get_table
          has_many_hash = {"id_#{principal_table}": @id, "id_#{secondary_table}": id}
          TADB::DB.table("#{principal_table}_#{secondary_table}").insert(has_many_hash)
        end
      end
      return @id
    end
  end

  def resfresh!
    check_id
    object_in_db = self.class.find_by_id(self.id)
    get_columns.each do |column|
      clase = column[:type]
      valor = object_in_db[column[:named]]
      if clase.respond_to?(:has_one)
        id = valor
        valor = clase.obtener_objeto_de_dominio(id)
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
    attr_accessor :columns, :descendientes

    def include(*includes)
      includes.each do |include|
        if include.respond_to?(:has_one)
          include.agregar_descendiente(self)
        end
      end
      super(*includes)
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

    def has_one(type, named:, **parametros_opcionales)
      columnas_de_superclase = []

      if self.respond_to?(:superclass)
        tiene_superclase_persistible = self.superclass.respond_to?(:has_one)
        if tiene_superclase_persistible
          columnas_de_superclase = (self.superclass.columns) ? self.superclass.columns : []
        end
      end

      modulos_persistibles_incluidos = included_modules.select do |x|
        x.respond_to?(:has_one)
      end
      columnas_de_todos = modulos_persistibles_incluidos.flat_map { |modulo| modulo.columns }
      unless @columns
        @columns = columnas_de_todos + columnas_de_superclase
      end
      # TODO: hace un test sobre que este declarado una property en una super clase y se pise en un sub clase
      add_column({'type': type, 'named': named, has_many: false}.merge(parametros_opcionales))
      attr_accessor named
    end

    def has_many(type, named:)
      handle_columns
      # TODO cambiar al metodo por add_column pero antes generar el test correspondiente
      @columns.push({'type': type, 'named': named, has_many: true})
      attr_accessor named
      # define_method(named) do
      #   value_getter = instance_variable_get("@#{named}")
      #   if value_getter.nil?
      #     return []
      #   else
      #     return value_getter
      #   end
      # end
      # define_method("#{named}=") do |value|
      #   instance_variable_set("@#{named}", value)
      # end
    end

    def add_column(nueva_columna)
      handle_columns
      hubo_reemplazo = false
      @columns = @columns.map { |columna|
        if columna[:named] == nueva_columna[:named]
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
      @columns.each { |columna|
        atributo = columna[:named]
        clase = columna[:type]
        valor = objeto_db[atributo]
        if clase.respond_to?(:has_one)
          id = valor
          valor = clase.obtener_objeto_de_dominio(id)
        end
        objeto.instance_variable_set("@#{atributo}", valor)
      }
      objeto.singleton_class.module_eval { attr_accessor :id }
      objeto.instance_variable_set("@id", objeto_db[:id])
      objeto
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