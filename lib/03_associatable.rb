require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.send(:table_name)
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] ||= (name.to_s+"_id").to_sym
    @class_name = options[:class_name] ||= name.to_s.capitalize
    @primary_key = options[:primary_key] ||= :id
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||= (self_class_name.to_s+"Id").underscore.to_sym
    @class_name = options[:class_name] ||= name.to_s.singularize.camelcase
    @primary_key = options[:primary_key] ||= :id
  end
end

module Associatable
  # Phase IIIb
  attr_writer :assoc_options

  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      opts = self.class.assoc_options[name]
      foreign_key_name = opts.foreign_key
      primary_key_name = opts.primary_key
      model_class = opts.model_class

      foreign_key_value = self.send(foreign_key_name)

      model_class.where({ primary_key_name => foreign_key_value }).first
    end

  end

  def has_many(name, options = {})
    options2 = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      foreign_key_name = options2.foreign_key
      primary_key_name = options2.primary_key
      model_class = options2.model_class
      primary_key_value = self.send(primary_key_name)

      model_class.where({foreign_key_name => primary_key_value})
    end
  end

  def assoc_options
    @assoc_options ||= {}
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end


end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
