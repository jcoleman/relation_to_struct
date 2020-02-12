module RelationToStruct::ActiveRecordRelationExtension
  def to_structs(struct_class)
    raise ArgumentError, 'Expected select_values to be present' unless self.select_values.present?

    relation = spawn

    # See the definition of #pluck in:
    # activerecord/lib/active_record/relation/calculations.rb
    result = nil
    if ActiveRecord::VERSION::MAJOR == 5 && ActiveRecord::VERSION::MINOR < 2
      result = klass.connection.select_all(relation.arel, nil, bound_attributes)
    else
      result = klass.connection.select_all(relation.arel)
    end

    if result.columns.size != struct_class.members.size
      raise ArgumentError, 'Expected struct fields and columns lengths to be equal'
    end

    if result.columns.size != result.columns.uniq.size
      raise ArgumentError, 'Expected column names to be unique'
    end

    values_after_casting = result.cast_values()

    if result.columns.size == 1
      values_after_casting.map do |tuple|
        struct_class.new(tuple)
      end
    else
      values_after_casting.map do |tuple|
        struct_class.new(*tuple)
      end
    end
  end
end

::ActiveRecord::Relation.send(:prepend, RelationToStruct::ActiveRecordRelationExtension)
