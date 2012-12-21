# -*- encoding: utf-8 -*-
require File.expand_path('../lib/status_column/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Maxim Filippovich"]
  gem.email         = ["fatumka@gmail.com"]
  gem.description   = %q{Allowcute status column}
  gem.summary       = %q{Status column}
  gem.homepage      = "http://twitter.com/mfilippovich"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "status_column"
  gem.require_paths = ["lib"]
  gem.version       = StatusColumn::VERSION

  gem.add_dependency 'state_machine'
  gem.add_dependency 'activesupport'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'activerecord'
  gem.add_development_dependency 'activerecord-nulldb-adapter'
end
