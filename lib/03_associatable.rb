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
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options[:primary_key].nil?
      self.primary_key = :id
    else
      self.primary_key = options[:primary_key]
    end

    if options[:foreign_key].nil?
      self.foreign_key = "#{name}_id".to_sym
    else
      self.foreign_key = options[:foreign_key]
    end
    
    if options[:class_name].nil?
      self.class_name = "#{name.camelcase}"
    else
      self.class_name = options[:class_name]
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options[:primary_key].nil?
      self.primary_key = :id
    else
      self.primary_key = options[:primary_key]
    end

    if options[:foreign_key].nil?
      self.foreign_key = "#{self_class_name}Id".underscore.to_sym
    else
      self.foreign_key = options[:foreign_key]
    end
    
    if options[:class_name].nil?
      self.class_name = name.singularize.camelcase
    else
      self.class_name = options[:class_name]
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      
    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
