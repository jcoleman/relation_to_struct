module RelationToStruct::ActiveRecordBaseExtension
  extend ::ActiveSupport::Concern

  module ClassMethods
    def structs_from_sql(struct_class, sql, binds=[])
      result = connection.select_all(sanitize_sql(sql, nil), "Structs SQL Load", binds)

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
      result = connection.select_all(sanitize_sql(sql, nil), "Pluck SQL Load", binds)
      result.cast_values()
    end

    def value_from_sql(sql, binds=[])
      result = connection.select_all(sanitize_sql(sql, nil), "Value SQL Load", binds)
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
      result = connection.select_all(sanitize_sql(sql, nil), "Value SQL Load", binds)
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
