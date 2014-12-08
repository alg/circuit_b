require 'simplecov'
require 'simplecov-rcov'

module SimpleCov
  module Formatter
    class MergedFormatter
      def format(result)
        SimpleCov::Formatter::HTMLFormatter.new.format(result)
        SimpleCov::Formatter::RcovFormatter.new.format(result)
      end
    end
  end
end

SimpleCov.start do
  minimum_coverage 100
  formatter SimpleCov::Formatter::MergedFormatter
  add_filter '/test/'
end

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/spec'
# require 'pry-rescue/minitest' # Uncomment this if you are debugging locally
require 'shoulda'
require 'timecop'

require 'circuit_b'
require 'circuit_b/configuration'
require 'circuit_b/storage'
require 'fakeredis'
require 'active_support'
require 'redis-activesupport'

# This is hacks but required to test Rails cache backend correctly
module Rails
  class << self
    attr_accessor :cache, :logger
  end
end

class MockLogger
  attr_reader :last

  def info(message)
    @last = message
  end

  def error(message)
    @last = message
  end
end

Rails.logger = MockLogger.new
Rails.cache = ActiveSupport::Cache.lookup_store :memory_store
