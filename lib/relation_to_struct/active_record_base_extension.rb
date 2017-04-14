module RelationToStruct::ActiveRecordBaseExtension
  extend ::ActiveSupport::Concern

  module ClassMethods
    def _sanitize_sql_for_relation_to_struct(sql)
      sanitized_sql = ActiveRecord::VERSION::MAJOR >= 5 ? sanitize_sql(sql) : sanitize_sql(sql, nil)
    end

    def structs_from_sql(struct_class, sql, binds=[])
      sanitized_sql = _sanitize_sql_for_relation_to_struct(sql)
      result = connection.select_all(sanitized_sql, "Structs SQL Load", binds)

      if result.columns.size != result.columns.uniq.size
        raise ArgumentError, 'Expected column names to be unique'
      end

      if result.columns != struct_class.members.collect(&:to_s)
        raise ArgumentError, 'Expected column names (and their order) to match struct attribute names'
      end

      if result.columns.size == 1
        result.cast_values().map do |tuple|
          struct_class.new(tuple)
        end
      else
        result.cast_values().map do |tuple|
          struct_class.new(*tuple)
        end
      end
    end

    def pluck_from_sql(sql, binds=[])
      sanitized_sql = _sanitize_sql_for_relation_to_struct(sql)
      result = connection.select_all(sanitized_sql, "Pluck SQL Load", binds)
      result.cast_values()
    end

    def value_from_sql(sql, binds=[])
      sanitized_sql = _sanitize_sql_for_relation_to_struct(sql)
      result = connection.select_all(sanitized_sql, "Value SQL Load", binds)
      raise ArgumentError, 'Expected exactly one column to be selected' unless result.columns.size == 1

      values = result.cast_values()
      case values.size
      when 0
        nil
      when 1
        values[0]
      else
        raise ArgumentError, 'Expected only a single result to be returned'
      end
    end

    def tuple_from_sql(sql, binds=[])
      sanitized_sql = _sanitize_sql_for_relation_to_struct(sql)
      result = connection.select_all(sanitized_sql, "Value SQL Load", binds)
      values = result.cast_values()

      case values.size
      when 0
        nil
      when 1
        result.columns.size == 1 ? values : values[0]
      else
        raise ArgumentError, 'Expected only a single result to be returned'
      end
    end
  end
end

::ActiveRecord::Base.send(:include, RelationToStruct::ActiveRecordBaseExtension)
