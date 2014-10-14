require 'fakeredis'
require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/spec'
# require 'pry-rescue/minitest' # Uncomment this if you are debugging locally
require 'shoulda'
require 'timecop'
require 'circuit_b'
require 'circuit_b/configuration'
require 'circuit_b/storage'
require 'active_support'
require 'redis-activesupport'

# This is hacks but required to test Rails cache backend correctly
module Rails
  class << self
    attr_accessor :cache
  end
end

Rails.cache = ActiveSupport::Cache.lookup_store :memory_store
