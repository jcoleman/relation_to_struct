require 'spec_helper'

describe RelationToStruct do
  before(:each) do
    Economist.delete_all
    EconomicSchool.delete_all
  end

  it 'ActiveRecord::Base should respond to :structs_from_sql' do
    expect(ActiveRecord::Base.respond_to?(:structs_from_sql)).to eq(true)
  end

  it 'should allow querying with SQL directly' do
    test_struct = Struct.new(:number)
    sql = "SELECT 1 * 23 AS number"
    expect(ActiveRecord::Base.structs_from_sql(test_struct, sql)).to eq([test_struct.new(23)])
  end

  it 'should allow plucking with SQL directly' do
    sql = "SELECT 1 * 23"
    expect(ActiveRecord::Base.pluck_from_sql(sql)).to eq([23])
  end

  it 'should allow plucking multiple columns with SQL directly' do
    sql = "SELECT 1 * 23, 25"
    expect(ActiveRecord::Base.pluck_from_sql(sql)).to eq([[23, 25]])
  end

  it 'structs_from_sql should properly cast a single array column' do
    Economist.create!(name: 'F.A. Hayek')
    Economist.create!(name: 'Ludwig von Mises')

    pluck_results = Economist.select('name').order('id').limit(1).pluck('array[name]') rescue nil
    if pluck_results
      expect(pluck_results).to eq([['F.A. Hayek']]) # Verify ActiveRecord interface.

      test_struct = Struct.new(:names)
      structs_results = ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT ARRAY_AGG(name ORDER BY id) AS names FROM economists')
      expect(structs_results.first.names).to eq(['F.A. Hayek', 'Ludwig von Mises'])
    else
      skip "DB selection doesn't support ARRAY[]"
    end
  end

  it 'structs_from_sql should raise an error when column count does not match struct size' do
    expect do
      test_struct = Struct.new(:id, :name, :extra_field)
      ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT id, name FROM economists')
    end.to raise_error(ArgumentError, 'Expected column names (and their order) to match struct attribute names')
  end

  it 'structs_from_sql should raise an error when column names are not unique' do
    expect do
      test_struct = Struct.new(:id, :id2)
      ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT id, id FROM economists')
    end.to raise_error(ArgumentError, 'Expected column names to be unique')
  end

  it 'structs_from_sql should raise an error when the column names do not match the struct attribute names' do
    Economist.create!(name: 'F.A. Hayek')
    expect do
      test_struct = Struct.new(:value_a, :value_b)
      ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT 1 AS value_a, 2 AS value_b FROM economists')
    end.not_to raise_error

    expect do
      test_struct = Struct.new(:value_a, :value_b)
      ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT 1 AS value_b, 2 AS value_a FROM economists')
    end.to raise_error(ArgumentError, 'Expected column names (and their order) to match struct attribute names')

    expect do
      test_struct = Struct.new(:value_a, :value_b)
      ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT 1 AS value_a, 2 AS value_c FROM economists')
    end.to raise_error(ArgumentError, 'Expected column names (and their order) to match struct attribute names')
  end
end
