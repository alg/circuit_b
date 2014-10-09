require File.dirname(__FILE__) + "/../../test_helper"
require "circuit_b/configuration"

class CircuitB::TestConfiguration < Minitest::Test

  def setup
    @config = CircuitB::Configuration.new
  end
  
  should "configure memory storage by default" do
    assert @config.state_storage.is_a?(CircuitB::Storage::Memory)
  end

  should "accept default fuse configuration updates" do
    @config.default_fuse_config = {
      :allowed_failures => 2,
      :cool_off_period => 3  # seconds
    }
  end
  
  should "add a named fuse with default configuration" do
    @config.fuse "fuse_name"
    assert_equal 1, @config.fuses.size
  end
  
  should "add a named fuse with custom configuration" do
    @config.fuse "fuse_name", :allowed_failures => 5
  end
  
  should "disallow adding fuses with the same name" do
    @config.fuse "fuse_name"
    begin
      @config.fuse "fuse_name"
      fail "should raise an exception"
    rescue
      # Exception is expected
    end
  end
end
