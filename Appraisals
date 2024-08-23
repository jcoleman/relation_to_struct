%w(6.1 7.0 7.1 7.2).each do |version|
  appraise "rails-#{version.gsub(/\./, "-")}" do
    gem "rails", "~> #{version}.0"
  end
end
