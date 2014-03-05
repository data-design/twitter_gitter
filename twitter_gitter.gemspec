# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twitter_gitter/version'

Gem::Specification.new do |spec|
  spec.name          = "twitter_gitter"
  spec.version       = TwitterGitter::VERSION
  spec.authors       = ["dannguyen"]
  spec.email         = ["dansonguyen@gmail.com"]
  spec.description   = %q{A light wrapper around the Ruby twitter gem, for demo purposes}
  spec.summary       = %q{A light wrapper around the Ruby twitter gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec", '>= 3.0.0.beta2'
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
  spec.add_dependency "twitter"
  spec.add_dependency "hashie"

end


