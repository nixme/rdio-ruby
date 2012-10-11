# -*- encoding: utf-8 -*-

require File.expand_path('../lib/rdio/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rdio-ruby'
  gem.version       = Rdio::VERSION
  gem.author        = 'Gopal Patel'
  gem.email         = 'nixme@stillhope.com'
  gem.license       = 'MIT'
  gem.homepage      = 'https://github.com/nixme/rdio-ruby'
  gem.summary       = 'A ruby wrapper for the Rdio Web Service API.'
  gem.description   = 'A ruby wrapper for the Rdio Web Service API.'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']

  # Dependencies
  gem.required_ruby_version = '>= 1.9.2'
  gem.add_runtime_dependency 'faraday', '~> 0.8'
  gem.add_runtime_dependency 'faraday_middleware', '~> 0.8.8'
  gem.add_runtime_dependency 'simple_oauth', '~> 0.1.9'
end
