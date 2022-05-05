%w(5.0 5.1 5.2 6.0 6.1 7.0).each do |version|
  appraise "rails-#{version.gsub(/\./, "-")}" do
    gem "rails", "~> #{version}.0"
    if version[0].to_i >= 6
      gem "sqlite3", "~> 1.4.0"
    else
      gem "sqlite3", "~> 1.3.0"
    end
  end
end
