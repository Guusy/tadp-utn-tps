require 'tadb'
module Orm
  def get_table
    self.class.name.downcase
  end

  def get_columns
    self.class.columns
  end

  def save!
    self.singleton_class.module_eval { attr_accessor :id }
    hash = {}
    get_columns.each do |column|
      hash[column] = self.send(column)
    end
    @id = TADB::DB.table(get_table).insert(hash)
  end

  def resfresh!
    unless self.respond_to?(:id)
      raise "Este objeto no esta persistido"
    end
    object_in_db = TADB::DB.table(get_table)
                       .entries
                       .select { |entry| entry[:id] === self.id }
                       .first
    get_columns.each do |column |
      self.instance_variable_set("@#{column}", object_in_db[column])
    end
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
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end