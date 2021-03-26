# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stepre/version'

Gem::Specification.new do |gem|
  gem.name          = "stepre"
  gem.version       = Stepre::VERSION
  gem.authors       = ["SoAwesomeMan"]
  gem.email         = ["callme@1800aweso.me"]
  gem.description   = %q{multi-step form gem}
  gem.summary       = %q{multi-step form gem for rails app}
  gem.homepage      = "http://github.com/windermere/stepre"

  gem.add_dependency('activemodel')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
