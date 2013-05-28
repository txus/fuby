# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fuby/version'

Gem::Specification.new do |spec|
  spec.name          = "fuby"
  spec.version       = Fuby::VERSION
  spec.authors       = ["Josep M. Bach"]
  spec.email         = ["josep.m.bach@gmail.com"]
  spec.description   = %q{Functional Ruby}
  spec.summary       = %q{A hybrid functional/object-oriented programming language on the Rubinius VM}
  spec.homepage      = "https://github.com/txus/fuby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "hamster"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
