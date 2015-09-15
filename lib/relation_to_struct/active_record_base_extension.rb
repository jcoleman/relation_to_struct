module RelationToStruct::ActiveRecordBaseExtension
  extend ::ActiveSupport::Concern

  module ClassMethods
    def structs_from_sql(struct_class, sql, binds=[])
      result = connection.select_all(sanitize_sql(sql, nil), "Structs SQL Load", binds)
      result.cast_values().map do |tuple|
        struct_class.new(*tuple)
      end
    end
  end
end

::ActiveRecord::Base.send(:include, RelationToStruct::ActiveRecordBaseExtension)
