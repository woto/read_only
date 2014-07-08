# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'read_only/version'

Gem::Specification.new do |spec|
  spec.name          = "read_only"
  spec.version       = ReadOnly::VERSION
  spec.authors       = ["Ruslan Kornev"]
  spec.email         = ["oganer@gmail.com"]
  spec.summary       = %q{The main advantage of using this gem is made encrpyted read only fields. Beaware of Replay Attacks.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/woto/readonly_attr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
