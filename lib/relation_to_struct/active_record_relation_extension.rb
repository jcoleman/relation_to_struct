module RelationToStruct::ActiveRecordRelationExtension
  extend ::ActiveSupport::Concern

  def to_structs(struct_class)
    raise '' unless self.select_values.present?

    relation = spawn
    result = klass.connection.select_all(relation.arel, nil, relation.arel.bind_values + bind_values)

    if result.columns.size != struct_class.members.size
      raise ArgumentError, 'Expected struct fields and columns lengths to be equal'
    end

    if result.columns.size != result.column_types.size
      raise ArgumentError, 'Expected unique column names count and column count to be equal'
    end

    result.cast_values(klass.column_types)

    if result.columns.size == 1
      result.cast_values(klass.column_types).map do |tuple|
        struct_class.new(tuple)
      end
    else
      result.cast_values(klass.column_types).map do |tuple|
        struct_class.new(*tuple)
      end
    end
  end
end

::ActiveRecord::Relation.send(:include, RelationToStruct::ActiveRecordRelationExtension)
