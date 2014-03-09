$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "internet_box_logger/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'internet_box_logger'
  s.version     = InternetBoxLogger::VERSION
  s.authors     = ['L.Briais']
  s.email       = ['lbnetid+rb@gmail.com']
  s.homepage    = 'https://github.com/lbriais/easy_app_helper'
  s.summary     = 'Rails engine that records stats from your internet box into elactic search.'
  s.description = 'Rails engine that records stats from your internet box into elactic search for potential later view into kibana.'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.3"
  s.add_dependency 'elasticsearch'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'

  s.add_development_dependency 'pry'
end
