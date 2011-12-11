require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/dsl_definition'

$LOAD_PATH.unshift("lib")
load 'tasks/prepare.rake'

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc 'Default: run tests'
task :default => [:test]
