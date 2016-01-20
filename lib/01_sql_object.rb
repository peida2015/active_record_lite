require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    db = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
    db.first.map {|col| col.to_sym}
  end

  def self.finalize!
    columns.each do |column|
      define_method "#{column}" do
        attributes[column]
      end

      define_method "#{column}=" do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= "#{self}".underscore + "s"
  end

  def self.all
    # ...
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
    self.parse_all(data)
  end

  def self.parse_all(results)
    # objects = []
    results.map do |attr_hash|
      self.new(attr_hash)
    end
  end

  def self.find(id)
    db = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
      SQL
      # debugger
    db.empty? ? nil : self.new(db.first)
  end

  def initialize(params = {})

    unless params.empty?
      self.class.finalize!
      cols = self.class.columns
      # debugger if cols
      params.keys.each do |col|
        if cols.include?(col.to_sym)
          send("#{col}=", params[col])
        else
          raise "unknown attribute \'#{col}\'"
        end
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map {|col| self.send("#{col}")}
  end

  def insert
    col_names = self.class.columns.join(',')
    questions_marks = (["?"]*self.class.columns.length).join(', ')

    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{questions_marks})
      SQL
    attributes[:id] = DBConnection.last_insert_row_id
    attribute_values
  end

  def update
    set_command = self.class.columns.map {|attr_name| "#{attr_name} = ?"}.join(', ')

    DBConnection.execute(<<-SQL, attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_command}
      WHERE
        id = ?
      SQL

    attribute_values
  end

  def save
    id.nil? ? insert : update
  end
end
