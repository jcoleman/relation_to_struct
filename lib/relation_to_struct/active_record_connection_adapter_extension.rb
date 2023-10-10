module RelationToStruct::ActiveRecordConnectionAdapterExtension
  def structs_from_sql(struct_class, sql, binds=[])
    sanitized_sql = ActiveRecord::Base.sanitize_sql(sql)
    result = ActiveRecord::Base.uncached do
      select_all(sanitized_sql, "Structs SQL Load", binds)
    end

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
    sanitized_sql = ActiveRecord::Base.sanitize_sql(sql)
    result = ActiveRecord::Base.uncached do
      select_all(sanitized_sql, "Pluck SQL Load", binds)
    end
    result.cast_values()
  end

  def value_from_sql(sql, binds=[])
    sanitized_sql = ActiveRecord::Base.sanitize_sql(sql)
    result = ActiveRecord::Base.uncached do
      select_all(sanitized_sql, "Value SQL Load", binds)
    end
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
    sanitized_sql = ActiveRecord::Base.sanitize_sql(sql)
    result = ActiveRecord::Base.uncached do
      select_all(sanitized_sql, "Value SQL Load", binds)
    end
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

  def run_sql(sql, binds=[])
    sanitized_sql = ActiveRecord::Base.sanitize_sql(sql)
    # We don't need to build a result set unnecessarily; using
    # interface this also ensures we're clearing the result set
    # for manually memory managed object (e.g., when using the
    # PostgreSQL adaptor).
    exec_update(sanitized_sql, "Run SQL", binds)
  end
end

::ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(RelationToStruct::ActiveRecordConnectionAdapterExtension)
