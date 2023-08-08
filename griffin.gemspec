# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'griffin/version'

Gem::Specification.new do |spec|
  spec.name          = 'griffin'
  spec.version       = Griffin::VERSION
  spec.authors       = ['Yuta Iwama']
  spec.email         = ['ganmacs@gmail.com']

  spec.summary       = 'gRPC server and client for Ruby'
  spec.description   = 'gRPC server and client for Ruby'
  spec.homepage      = 'https://github.com/ganmacs/griffin'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib pb]

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version             = Gem::Requirement.new('>= 3.0')

  spec.add_dependency 'grpc_kit', '>= 0.5.0'
  spec.add_dependency 'serverengine', '~> 2.0.7'
end
