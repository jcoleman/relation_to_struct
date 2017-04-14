# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relation_to_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "relation_to_struct"
  spec.version       = RelationToStruct::VERSION
  spec.authors       = ["James Coleman"]
  spec.email         = ["jtc331@gmail.com"]
  spec.summary       = %q{Return struct results from ActiveRecord relation queries}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "appraisal", "~> 2.1"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pg"

  spec.add_dependency "activerecord", ">= 4.1", "< 5.1"
  spec.add_dependency "activesupport", ">= 4.1", "< 5.1"
end
