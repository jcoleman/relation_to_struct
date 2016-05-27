%w(4.1 4.2).each do |version|
  appraise "rails-#{version.gsub(/\./, "-")}" do
    gem "rails", "~> #{version}.0"
  end
end
