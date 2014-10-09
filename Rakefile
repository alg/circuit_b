# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/**/test_*'
  t.test_files = ['test/test_helper.rb']
  t.verbose = true
end

task default: :test
