require 'tadb'
module Orm
  def save!
    singleton_class.module_eval { attr_accessor :id}
    @id = "0"
  end

  def resfresh!
    raise "Este objeto no esta persistido"
  end
  module ClassMethods
    def has_one(i, named:)
      attr_accessor named
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end