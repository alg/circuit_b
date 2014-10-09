# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.pattern = 'test/unit/**/test_*'
  t.test_files = ['test/test_helper.rb']
  t.verbose = false
end

RuboCop::RakeTask.new(:rubocop)

task default: [:rubocop, :test]
