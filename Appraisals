%w(4.1 4.2 5.0 5.1).each do |version|
  appraise "rails-#{version.gsub(/\./, "-")}" do
    gem "rails", "~> #{version}.0"
  end
end
