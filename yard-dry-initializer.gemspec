# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yard/dry/initializer/version'

Gem::Specification.new do |spec|
  spec.name          = 'yard-dry-initializer'
  spec.version       = YARD::Dry::Initializer::VERSION
  spec.authors       = ['Andrey Novikov']
  spec.email         = ['envek@envek.name']

  spec.summary       = 'Generates documentation for your params and options'
  spec.description   = <<~MSG
    Generates for you all YARD declarations of attributes
    and initializer parameters created by dry-initializer gem.
  MSG
  spec.homepage      = 'https://github.com/Envek/yard-dry-initializer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'yard', '>= 0.9'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
