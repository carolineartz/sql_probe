module SqlProbe
  module Utils
    module_function

    def reject_gem_paths(caller)
      caller.reject{|r| Gem.default_path.detect{|d| r.include?(d)} }
    end

    def pretty_sql(sql)
      remove_redundant_sql_quotes(sql)
        .gsub(/\s+(SELECT|FROM|WHERE|GROUP|HAVING|LEFT JOIN|LEFT OUTER JOIN|INNER JOIN|JOIN|RIGHT|ORDER|WINDOW|AND|OR)\b/, "\n\\1")
    end

    def remove_redundant_sql_quotes(sql)
      sql.gsub(/(")([\S]+?)\1/, '\2')
    end

    REPLACEMENT_PATTERNS = [
      UUID_PATTERN = '[0-9a-f]{8}(\\\-[0-9a-f]{4}){3}\\\-[0-9a-f]{12}',
      OBJECT_IDS   = '0x[0-9a-f]+',
      GENERAL_IDS  = '\d{5,}'
    ]

    def replace_varying_ids(sql)
      line = Regexp.escape(sql)
      REPLACEMENT_PATTERNS.each do |pattern|
        line.gsub!(/#{pattern}/, pattern)
      end
      line
    end
  end
end
