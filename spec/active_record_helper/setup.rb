ActiveRecord::Base.configurations = {
  "postgresql" => {
    "adapter" => 'postgresql',
    "host" => 'localhost',
    "database" => 'relation_to_struct_tests',
    "encoding" => 'utf8',
    "username" => ENV["PGUSER"] || 'postgres',
    "password" => ENV["PGPASSWORD"] || 'postgres',
  },
  "sqlite" => {
    "adapter"  => "sqlite3",
    "database" => ":memory:",
  },
}

env = ENV['DATABASE'] ||= 'sqlite'
config = ActiveRecord::Base.configurations.configs_for(env_name: env).first

case env
when 'postgresql'
  ActiveRecord::Tasks::DatabaseTasks.instance_variable_set('@env', env)
  ActiveRecord::Tasks::DatabaseTasks.drop_current
  ActiveRecord::Tasks::DatabaseTasks.create_current
  ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:ruby, File.expand_path('../schema.rb', __FILE__))
  ActiveRecord::Base.establish_connection(config)
when 'sqlite'
  ActiveRecord::Base.establish_connection(config)
  require_relative 'schema'
else
  raise ArgumentError, 'Unrecognized ENV["DATABASE"] argument.'
end

require_relative 'economic_school'
require_relative 'economist'
