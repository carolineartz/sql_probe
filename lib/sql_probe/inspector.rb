module SqlProbe
  # Provides inspection helpers to get interesting
  # facts about a SQL statement.
  class Inspector
    def initialize(sql)
      @sql = sql
    end

    def insert?
      insert_table.present?
    end

    def delete?
      delete_table.present?
    end

    def update?
      update_table.present?
    end

    def select?
      !(insert? || update? || delete?)
    end

    def insert_table
      clean_sql[/\bINSERT\s+INTO\s+(\w+|"[\w ]+")/im, 1]
    end

    def delete_table
      clean_sql[/\bDELETE\s+FROM\s+(\w+|"[\w ]+")/im, 1]
    end

    def update_table
      # ex: update foo, baz set 
      clean_sql[/\bUPDATE\s+(.+?)\s+(SET|,)/im, 1]
    end

    def data_sources
      parts = clean_sql.split(/\W+/)
      parts & self.all_data_sources
    end

    def self.all_data_sources
      @data_sources ||= ActiveRecord::Base.connection.data_sources
    end

    private

    def remove_redundant_quotes(sql)
      sql.gsub(/(")([\S]+?)\1/, '\2')
    end

    def clean_sql
      @clean_sql ||= remove_redundant_quotes(@sql)
    end
  end
end
