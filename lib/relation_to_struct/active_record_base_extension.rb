module RelationToStruct::ActiveRecordBaseExtension
  module ClassMethods
    def _sanitize_sql_for_relation_to_struct(sql)
      sanitized_sql = ActiveRecord::VERSION::MAJOR >= 5 ? sanitize_sql(sql) : sanitize_sql(sql, nil)
    end

    delegate(
      :structs_from_sql,
      :pluck_from_sql,
      :value_from_sql,
      :tuple_from_sql,
      :run_sql,
      :to => :connection
    )
  end
end

::ActiveRecord::Base.singleton_class.send(:prepend, RelationToStruct::ActiveRecordBaseExtension::ClassMethods)
