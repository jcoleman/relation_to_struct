module RelationToStruct::ActiveRecordBaseExtension
  module ClassMethods
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

::ActiveRecord::Base.singleton_class.prepend(RelationToStruct::ActiveRecordBaseExtension::ClassMethods)
