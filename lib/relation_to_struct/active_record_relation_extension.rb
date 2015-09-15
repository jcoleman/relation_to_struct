module RelationToStruct::ActiveRecordRelationExtension
  extend ::ActiveSupport::Concern

  def to_structs(struct_class)
    raise '' unless self.select_values.present?

    relation = spawn
    result = klass.connection.select_all(relation.arel, nil, relation.arel.bind_values + bind_values)
    result.cast_values(klass.column_types)

    result.cast_values(klass.column_types).map do |tuple|
      struct_class.new(*tuple)
    end
  end
end

::ActiveRecord::Relation.send(:include, RelationToStruct::ActiveRecordRelationExtension)
