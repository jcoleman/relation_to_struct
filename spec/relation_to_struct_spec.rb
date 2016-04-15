require 'spec_helper'

describe RelationToStruct do
  before(:each) do
    Economist.delete_all
    EconomicSchool.delete_all
  end

  it 'has a version number' do
    expect(RelationToStruct::VERSION).not_to be nil
  end

  describe 'relation' do
    it 'should respond to :to_structs' do
      expect(Economist.all.respond_to?(:to_structs)).to eq(true)
    end

    it '#to_structs should raise an error when the relation has no select_values' do
      expect do
        Economist.all.to_structs(Struct.new(:test_struct))
      end.to raise_error
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

  describe 'non-model specific querying' do
    it 'ActiveRecord::Base should respond to :structs_from_sql' do
      expect(ActiveRecord::Base.respond_to?(:structs_from_sql)).to eq(true)
    end

    it 'should allow querying with SQL directly' do
      test_struct = Struct.new(:number)
      sql = "SELECT 1 * 23"
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
        structs_results = ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT ARRAY_AGG(name ORDER BY id) FROM economists')
        expect(structs_results.first.names).to eq(['F.A. Hayek', 'Ludwig von Mises'])
      else
        skip "DB selection doesn't support ARRAY[]"
      end
    end

    it 'structs_from_sql should raise an error when column count does not match struct size' do
      expect do
        test_struct = Struct.new(:id, :name, :extra_field)
        ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT id, name FROM economists')
      end.to raise_error(ArgumentError, 'Expected struct fields and columns lengths to be equal')
    end

    it 'structs_from_sql should raise an error when column names are not unique' do
      expect do
        test_struct = Struct.new(:id, :id2)
        ActiveRecord::Base.structs_from_sql(test_struct, 'SELECT id, id FROM economists')
      end.to raise_error(ArgumentError, 'Expected column names to be unique')
    end
  end
end
