# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundler/advise/version'

Gem::Specification.new do |spec|
  spec.name          = 'bundler-advise'
  spec.version       = Bundler::Advise::VERSION
  spec.authors       = ['chrismo']
  spec.email         = ['chrismo@clabs.org']

  spec.summary       = %q{Scans Gemfile for known vulnerable gems.}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/chrismo/bundler-advise'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'git'
  spec.add_dependency 'bundler', '~> 1.7'

  spec.add_development_dependency 'bundler-fixture', '~> 1.3', '>= 1.3.2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
