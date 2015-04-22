require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      home_table = self.class.table_name

      through_table = through_options.model_class.table_name
      through_foreign_key = through_options.foreign_key
      through_primary_key = through_options.primary_key

      source_table = source_options.model_class.table_name
      source_foreign_key = source_options.foreign_key
      source_primary_key = source_options.primary_key

      result = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{source_table}.*
        FROM
          #{home_table}
        JOIN
          #{through_table}
        ON
          #{home_table}.#{through_foreign_key} = #{through_table}.#{through_primary_key}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{home_table}.id = ?
      SQL
      source_options.model_class.new(result.first)
    end
  end
end
