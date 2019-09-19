require 'tadb'
module Orm
  def save!
    self.singleton_class.module_eval { attr_accessor :id }
    hash = {}
    self.class.columns.each do | column |
      hash[column] = self.send(column)
    end
    @id = TADB::DB.table(self.class.name.downcase).insert(hash)
  end

  def resfresh!
    unless self.respond_to?(:id)
      raise "Este objeto no esta persistido"
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