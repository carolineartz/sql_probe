module SqlProbe
  # Parse YAML event data into a list of INSERT, UPDATE, DELETE, and SELECT
  # counts per table.
  class StatementList
    include Enumerable

    def initialize(path: SqlProbe.output_base_dir)
      @path = path
      @files = Dir["#{@path}/**/*.yml"]
    end

    def each
      each_yaml do |path, yaml|
        yaml['events'].each do |event|
          yield event_row(path, yaml, event)
        end
      end
    end

    def event_row(path, yaml, event)
      {
        path:   path,
        mtime:  File.mtime(path),
        name:   yaml['name'],
        tables: table_summary(event['sql'])
      }
    end

    def each_yaml
      @files.map do |path|
        yield path, YAML.load(File.read(path))
      end
    end

    # @return [Hash<String,String>] table_name => action (SELECT|INSERT|UPDATE|DELETE)
    def table_summary(sql)
      ins = Inspector.new(sql)
      action = ins.action
      ins.action_tables.each_with_object({}) do |table, agg|
        agg[table] = action
      end
    end

    def parse_events_file(path)
      sql_stats = data['events']
                  .map { |m| parse_sql(m['sql']) }
                  .compact

      {
        path: path,
        file_ts: File.mtime(path),
        controller: data['params']['controller'],
        action: data['params']['action'],
        stats: sql_stats
      }
    end
  end
end
