require_relative '02_searchable'
require 'active_support/inflector'

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
      self.class_name = "#{name.to_s.camelcase}"
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
      self.class_name = name.to_s.singularize.camelcase
    else
      self.class_name = options[:class_name]
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key = self.send(options.foreign_key)
      klass = options.model_class
      klass.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key = self.send(options.primary_key)
      klass = options.model_class
      klass.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
