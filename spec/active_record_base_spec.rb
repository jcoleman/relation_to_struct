require 'spec_helper'

describe ActiveRecord::Base do
  before(:each) do
    Economist.delete_all
    EconomicSchool.delete_all
  end

  describe "#pluck_from_sql" do
    it 'allows plucking with SQL directly' do
      sql = "SELECT 1 * 23"
      expect(ActiveRecord::Base.pluck_from_sql(sql)).to eq([23])
    end

    it 'allows plucking multiple columns with SQL directly' do
      sql = "SELECT 1 * 23, 25"
      expect(ActiveRecord::Base.pluck_from_sql(sql)).to eq([[23, 25]])
    end
  end

  describe "#value_from_sql" do
    it 'allows selecting a value with SQL directly' do
      sql = "SELECT 1 * 23"
      expect(ActiveRecord::Base.value_from_sql(sql)).to eq(23)
    end

    it 'raises an error when multiple rows are selected' do
      expect do
        sql = "SELECT * FROM (VALUES (1), (2)) t"
        ActiveRecord::Base.value_from_sql(sql)
      end.to raise_error(ArgumentError, 'Expected only a single result to be returned')
    end

    it 'raises an error when multiple columns are selected' do
      expect do
        sql = "SELECT 1, 2"
        ActiveRecord::Base.value_from_sql(sql)
      end.to raise_error(ArgumentError, 'Expected exactly one column to be selected')
    end

    it 'supports binds' do
      sql = ["SELECT 1 * ?", 5]
      expect(ActiveRecord::Base.value_from_sql(sql)).to eq(5)
    end

    it 'supports arrays' do
      if active_record_supports_arrays?
        Economist.create!(name: 'F.A. Hayek')
        Economist.create!(name: 'Ludwig von Mises')

        result = ActiveRecord::Base.value_from_sql('SELECT ARRAY_AGG(name ORDER BY id) AS names FROM economists')
        expect(result).to eq(['F.A. Hayek', 'Ludwig von Mises'])
      else
        skip "DB selection doesn't support ARRAY[]"
      end
    end
  end

  describe "#structs_from_sql" do
    it 'ActiveRecord::Base should respond to :structs_from_sql' do
      expect(ActiveRecord::Base.respond_to?(:structs_from_sql)).to eq(true)
    end

    it 'allows querying with SQL directly' do
      test_struct = Struct.new(:number)
      sql = "SELECT 1 * 23 AS number"
      expect(ActiveRecord::Base.structs_from_sql(test_struct, sql)).to eq([test_struct.new(23)])
    end

    it 'properly casts a single array column' do
      if active_record_supports_arrays?
        Economist.create!(name: 'F.A. Hayek')
        Economist.create!(name: 'Ludwig von Mises')

        test_struct = Struct.new(:names)
        structs_results = ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT ARRAY_AGG(name ORDER BY id) AS names FROM economists')
        expect(structs_results.first.names).to eq(['F.A. Hayek', 'Ludwig von Mises'])
      else
        skip "DB selection doesn't support ARRAY[]"
      end
    end

    it 'raises an error when column count does not match struct size' do
      expect do
        test_struct = Struct.new(:id, :name, :extra_field)
        ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT id, name FROM economists')
      end.to raise_error(ArgumentError, 'Expected column names (and their order) to match struct attribute names')
    end

    it 'raises an error when column names are not unique' do
      expect do
        test_struct = Struct.new(:id, :id2)
        ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT id, id FROM economists')
      end.to raise_error(ArgumentError, 'Expected column names to be unique')
    end

    it 'raises an error when the column names do not match the struct attribute names' do
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
end
