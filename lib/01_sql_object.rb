require_relative 'db_connection'
require 'byebug'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    columns = data.first.map(&:to_sym)

    columns
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        @attributes[column]
      end
      define_method("#{column}=") do |new_attr|
        attributes[column] = new_attr
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}

    SQL

    parse_all(data)

  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    obj = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
      LIMIT
        1
    SQL
    return nil if obj.empty?
    self.new(obj.first)

  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name}=", value)
    end
    attributes
  end

  def attributes
    @attributes ||= Hash.new {|h,k| h[k]=nil}
  end

  def attribute_values
    # byebug
    self.class.columns.map { |col| send(col)}
    # ...
  end

  def insert
    # byebug
    self.id = self.class.all.length + 1
    col_names = attributes.keys.inspect.gsub(/[^0-9A-Za-z, _]/, '')
    col_syms = attributes.keys.inspect.gsub(/[^0-9A-Za-z, _:]/, '')

    DBConnection.execute(<<-SQL, attributes)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{col_syms})
    SQL
  end

  def update
    set_str = ""
    attr_strings = attributes.keys
    attr_values = attributes.values
    # byebug
    attr_strings.each_index do |i|
      set_str << "#{attr_strings[i]} = '#{attr_values[i]}'"

      set_str << ", " unless i == attr_strings.length - 1

    end
    # byebug
    DBConnection.execute(<<-SQL, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_str}
      WHERE
        id = ?
    SQL


  end

  def save

    if id.nil?
      self.insert
    else
      self.update
    end
  end

end
