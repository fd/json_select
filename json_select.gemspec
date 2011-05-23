# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "json_select/version"

Gem::Specification.new do |s|
  s.name        = "json_select"
  s.version     = JSONSelect::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Simon Menke"]
  s.email       = ["simon.menke@gmail.com"]
  s.homepage    = "http://github.com/fd/json_select"
  s.summary     = %q{JSONSelect implementation for Ruby}
  s.description = %q{JSONSelect implementation for Ruby}

  s.rubyforge_project = "json_select"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'treetop'
end
