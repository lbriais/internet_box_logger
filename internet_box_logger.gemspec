# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'internet_box_logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'internet_box_logger'
  spec.version       = InternetBoxLogger::VERSION
  spec.authors       = ['Laurent B']
  spec.email         = ['lbnetid+gh@gmail.com']
  spec.summary       = %q{Monitor your internet box.}
  spec.description   = %q{Logs information gathered from your internet box and stores into ElasticSearch for display into Kibana.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1' # (3.1.0)
  spec.add_development_dependency 'pry'

  spec.add_dependency 'activesupport'# , '~> 4.1' # (4.1.8)
  spec.add_dependency 'whenever'# , '~> 0.9' # (0.9.4)
  spec.add_dependency 'easy_app_helper', '~> 2.0' # , '~> 1.0'
  spec.add_dependency 'elasticsearch'# , '~> 1.0' # (1.0.6)

end
