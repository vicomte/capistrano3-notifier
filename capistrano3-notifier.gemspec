# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano/notifier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Campbell", "Nathan L Smith", "Vitaly Gorodetsky"]
  gem.email         = ["sysadmin@cramerdev.com"]
  gem.summary       = %q{Capistrano3 Notifier}
  gem.description   = %q{Simple notification hooks for Capistrano3}
  gem.homepage      = "https://github.com/applicaster/capistrano3-notifier"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.name          = "capistrano3-notifier"
  gem.require_paths = ["lib"]
  gem.version       = Capistrano::Notifier::VERSION

  gem.add_dependency 'actionmailer', '~> 4.0'
  gem.add_dependency 'capistrano', '~> 3.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'timecop'
  gem.add_development_dependency 'pry'
end
