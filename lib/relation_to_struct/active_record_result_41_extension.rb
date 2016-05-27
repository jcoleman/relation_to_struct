module RelationToStruct::ActiveRecord41ResultExtension
  extend ::ActiveSupport::Concern

  included do
    alias_method_chain :column_type, :ar_42_semantics
  end

  def cast_values(type_overrides = {}) # :nodoc:
    types = columns.map { |name| column_type(name, type_overrides) }
    result = rows.map do |values|
      types.zip(values).map { |type, value| type.type_cast(value) }
    end

    columns.one? ? result.map!(&:first) : result
  end

  def column_type_with_ar_42_semantics(name, type_overrides = {})
    type_overrides.fetch(name) do
      column_types.fetch(name, ::ActiveRecord::Result::IDENTITY_TYPE)
    end
  end
end

if ActiveRecord.version < Gem::Version.new("4.2.0")
  ::ActiveRecord::Result.send(:include, RelationToStruct::ActiveRecord41ResultExtension)
end
