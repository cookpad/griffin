# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'griffin/version'

Gem::Specification.new do |spec|
  spec.name          = 'griffin'
  spec.version       = Griffin::VERSION
  spec.authors       = ['ganmacs']
  spec.email         = ['ganmacs@gmail.com']

  spec.summary       = 'Send and Receive RPCs from Ruby'
  spec.description   = 'Send and Receive RPCs from Ruby'
  spec.homepage      = 'https://github.com/ganmacs/griffin'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'grpc_kit', '~> 0.1.2'
  spec.add_dependency 'serverengine', '~> 2.0.7'
end
