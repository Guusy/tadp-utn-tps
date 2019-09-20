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
      hash[column] = self.send(column)
    end
    @id = TADB::DB.table(get_table).insert(hash)
    self.class.add_column(:id)
  end

  def resfresh!
    check_id
    object_in_db = TADB::DB.table(get_table)
                       .entries
                       .select { |entry| entry[:id] === self.id }
                       .first
    get_columns.each do |column|
      self.instance_variable_set("@#{column}", object_in_db[column])
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
      get_columns.each do |column |
        domain_object.instance_variable_set("@#{column}", entry[column])
      end
      domain_object
    }
  end

  module ClassMethods
    attr_accessor :columns

    def has_one(i, named:)
      unless @columns
        @columns = []
      end
      @columns.push(named)
      attr_accessor named
    end

    def add_column(column)
      unless @columns
        @columns = []
      end
      @columns.push(column)

    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end