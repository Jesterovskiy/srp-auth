# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'srp/auth/version'

Gem::Specification.new do |spec|
  spec.name          = "srp-auth"
  spec.version       = Srp::Auth::VERSION
  spec.authors       = ["Jester"]
  spec.email         = ["jester@aejis.eu"]
  spec.summary       = %q{SRP protocol}
  spec.description   = %q{SRP protocol for ruby and JS}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "warden", "~> 1.2.3"
  spec.add_development_dependency "faker", "~> 1.4.3"
  spec.add_development_dependency "fakeredis", "~> 0.5.0"
end
