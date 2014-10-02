# encoding: utf-8
require 'rubygems'
require 'rake'
$:.unshift(File.dirname(__FILE__) + '/lib')
 
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "circuit_b"
    gem.version     = "1.1"
    gem.summary     = %Q{Distributed circuit breaker}
    gem.description = %Q{Classic circuit breaker to protect resources from being accessed over and over while in pain.}
    gem.email       = "spyromus@noizeramp.com"
    gem.homepage    = "http://github.com/alg/circuit_b"
    gem.authors     = ["Aleksey Gureiev"]
 
    gem.add_development_dependency 'shoulda', '>= 2.10.3'
    gem.add_development_dependency 'timecop', '>= 0.3.4'
  end
 
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
 
Dir['gem_tasks/**/*.rake'].each { |rake| load rake }
 
task :default => [:test]
 
require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc})
