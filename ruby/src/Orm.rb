module Orm
  def has_one(i, named:)
    attr_accessor named
  end

end