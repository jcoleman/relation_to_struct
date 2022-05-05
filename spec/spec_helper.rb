$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'active_support'
require 'relation_to_struct'
require 'active_record_helper/setup'
require 'pry-byebug'

def active_record_supports_arrays?
  if defined?(@active_record_supports_arrays)
    @active_record_supports_arrays
  else
    supports_arrays = false
    ActiveRecord::Base.transaction do
      Economist.create!(name: 'F.A. Hayek')
      Economist.create!(name: 'Ludwig von Mises')

      pluck_results = Economist.select('name').order('id').limit(1).pluck(Arel.sql('array[name]'))  rescue nil
      if pluck_results
        raise StandardError, "Unexpected array query results" unless pluck_results == [['F.A. Hayek']] # Verify ActiveRecord interface.
        supports_arrays = true
      end

      raise ActiveRecord::Rollback
    end
    @active_record_supports_arrays = supports_arrays
  end
end
