%w(5.0 5.1 5.2).each do |version|
  appraise "rails-#{version.gsub(/\./, "-")}" do
    gem "rails", "~> #{version}.0"
  end
end
