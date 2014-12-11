require_relative 'db_connection'
require 'active_support/inflector'
require 'debugger'

class SQLObject
  def self.columns
    arr = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      "#{self.table_name}"
    SQL
    arr.first.map{|element| element.to_sym}
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        @attributes ||= {}
        @attributes[column]
      end
      
      define_method("#{column}=") do |arg|
        @attributes ||= {}
        @attributes[column] = arg
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      "#{self.table_name}"
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    objects_arr = []
    results.each do |result|
      objects_arr << self.new(result)
    end
    objects_arr
  end

  def self.find(id)
    sql = <<-SQL
    SELECT
      *
    FROM
      "#{self.table_name}"
    WHERE
      id = ?
    LIMIT
      1
    SQL
     self.new(DBConnection.execute(sql, id).first)
  end

  def initialize(params = {})    
    @attributes ||= {}
    columns = self.class.columns
    params.each do |key, value|
      unless columns.include?(key.to_sym)
        raise "unknown attribute '#{key}'"
      end
      @attributes[key.to_sym] = value
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    return_arr = []
    @attributes.each_value { |value| return_arr << value}
    return_arr
  end

  def insert
    columns = self.class.columns[1..-1].join(', ')
    question_marks = ['?'] * (self.class.columns.length - 1)
    question_marks = question_marks.join(', ')
    sql = <<-SQL
    INSERT INTO
    '#{self.class.table_name}' (#{columns})
    VALUES
    (#{question_marks})
    SQL
    DBConnection.execute(sql, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns[1..-1].map {|attr| "#{attr} = ?"}.join(', ')
    sql = <<-SQL
    UPDATE
      '#{self.class.table_name}'
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
    DBConnection.execute(sql, *attribute_values[1..-1], self.id)
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
