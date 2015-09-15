ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :economic_schools do |t|
    t.string :name
  end

  create_table :economists do |t|
    t.string :name
    t.references :economic_school
  end
end
