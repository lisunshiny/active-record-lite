load "lib/01_sql_object.rb"
load "lib/db_connection.rb"
load "lib/02_searchable.rb"
load "lib/03_associatable.rb"
load "lib/04_associatable2.rb"

class Cat < SQLObject
  self.finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  self.finalize!
end
