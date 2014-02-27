$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "freebox_logger/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'freebox_logger'
  s.version     = FreeboxLogger::VERSION
  s.authors     = ['L.Briais']
  s.email       = ['lbnetid+rb@gmail.com']
  s.homepage    = 'https://github.com/lbriais/easy_app_helper'
  s.summary     = 'Rails engine that records stats from the Freebox into elactic search.'
  s.description = 'Rails engine that records stats from the Freebox into elactic search for potential later view into kibana.'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.3"
  s.add_dependency 'elasticsearch'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec'
end
