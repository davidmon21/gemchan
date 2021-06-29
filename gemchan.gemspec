# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "gemchan/version"

Gem::Specification.new do |s|
  s.name        = "gemchan"
  s.version     = Gemchan::VERSION
  s.author      = "david"
  s.email       = ["david.monfort1989@gmail.com"]
  s.homepage    = "https://github.com/quietok/gemchan"
  s.license     = "MIT"
  s.summary     = "not now"
  s.description = "not now"
  
  s.files         = ["lib/gemchan.rb", "lib/gemchan/model.rb","lib/gemchan/server.rb", "lib/gemchan/version.rb", "lib/gemchan/controller.rb"]
  s.executables   = ["gemchan"]
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.6'

  # s.add_runtime_dependency "foo"
  s.add_development_dependency "rspec"
end
