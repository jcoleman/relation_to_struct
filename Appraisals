%w(7.0 7.1 7.2 8.0 8.1).each do |version|
  appraise "rails-#{version.gsub(/\./, "-")}" do
    gem "rails", "~> #{version}.0"
    gem "sqlite3", "~> 1.4" if version == "7.0"
  end
end
