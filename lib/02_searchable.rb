require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    str = ""

    params.each do |key, value|
      str << " #{key} = ? AND"
    end
    # byebug
    params = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{str[0..-5]}
    SQL
    # byebug
    params.map{ |param| self.new(param) }

  end
end

class SQLObject
  extend Searchable
end
