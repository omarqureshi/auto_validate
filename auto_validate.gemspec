# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "auto_validate/version"

Gem::Specification.new do |s|
  s.name        = "auto_validate"
  s.version     = AutoValidate::VERSION
  s.authors     = ["Omar Qureshi"]
  s.email       = ["omar@omarqureshi.net"]
  s.homepage    = "http://omarqureshi.net"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "auto_validate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for
  s.add_development_dependency "shoulda"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "pg"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "bcrypt-ruby"
  s.add_development_dependency "database_cleaner"
  s.add_runtime_dependency "rails"

  # s.add_development_dependency "mysql"
  # s.add_development_dependency "sqlite"
  # s.add_runtime_dependency "rest-client"
end
