require 'spec_helper'

describe RelationToStruct do
  before(:each) do
    Economist.delete_all
    EconomicSchool.delete_all
  end

  it 'should respond to :to_structs' do
    expect(Economist.all.respond_to?(:to_structs)).to eq(true)
  end

  it '#to_structs should raise an error when the relation has no select_values' do
    expect do
      Economist.all.to_structs(Struct.new(:test_struct))
    end.to raise_error(ArgumentError, 'Expected select_values to be present')
  end

  it '#to_structs should return an empty array when no results are returned' do
    expect(Economist.where('1 = 0').select(:id).to_structs(Struct.new(:test_struct))).to eq([])
  end

  it '#to_structs should return an array with struct instances' do
    hayek = Economist.create!(name: 'F.A. Hayek')
    id_struct = Struct.new(:id)
    expect(Economist.all.select(:id).to_structs(id_struct)).to eq([id_struct.new(hayek.id)])
  end

  it '#to_structs should handle joined elements properly' do
    austrian = EconomicSchool.create!(name: 'Austrian Economics')
    hayek = Economist.create!(name: 'F.A. Hayek', economic_school: austrian)
    test_struct = Struct.new(:name, :school)
    expect(
      Economist
        .joins(:economic_school)
        .select('economists.name', 'economic_schools.name as school_name')
        .to_structs(test_struct)
    ).to eq([test_struct.new(hayek.name, austrian.name)])
  end

  it '#to_structs should properly cast values from arbitrary calculated columns' do
    hayek = Economist.create!(name: 'F.A. Hayek')
    scope = Economist.all
    pluck_results = scope.pluck("date('now')")
    pluck_column_klass = pluck_results.first.class

    date_struct = Struct.new(:date)
    struct_scope = scope.select("date('now')")
    structs_results = struct_scope.to_structs(date_struct)
    struct_column_klass = structs_results.first.date.class
    expect(pluck_column_klass).to eq(struct_column_klass)
  end

  it '#to_structs should properly cast a single array column' do
    Economist.create!(name: 'F.A. Hayek')

    pluck_results = Economist.select('name').pluck('array[name]') rescue nil
    if pluck_results
      expect(pluck_results).to eq([['F.A. Hayek']]) # Verify ActiveRecord interface.

      test_struct = Struct.new(:names)
      structs_results = Economist.select('array[name]').to_structs(test_struct)
      expect(structs_results.first.names).to eq(['F.A. Hayek'])
    else
      skip "DB selection doesn't support ARRAY[]"
    end
  end

  it '#to_structs should raise an error when column count does not match struct size' do
    expect do
      test_struct = Struct.new(:id, :name, :extra_field)
      Economist.select('id, name').to_structs(test_struct)
    end.to raise_error(ArgumentError, 'Expected struct fields and columns lengths to be equal')
  end

  it '#to_structs should raise an error when column names are not unique' do
    expect do
      test_struct = Struct.new(:id, :id2)
      Economist.select('id, id').to_structs(test_struct)
    end.to raise_error(ArgumentError, 'Expected column names to be unique')
  end
end
