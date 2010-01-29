require File.dirname(__FILE__) + "/../../test_helper"
require "circuit_b"

class CircuitB::TestFuse < Test::Unit::TestCase
  
  context "initialization" do
    should "not allow nil names" do
      begin
        CircuitB::Fuse.new(nil, nil, {})
        fail "Exception is expected"
      rescue => e
        assert_equal "Name must be specified", e.message
      end
    end

    should "not allow nil-storages" do
      begin
        CircuitB::Fuse.new("name", nil, {})
        fail "Exception is expected"
      rescue => e
        assert_equal "Storage must be specified", e.message
      end
    end

    should "disallow storages of the wrong type" do
      begin
        CircuitB::Fuse.new("name", "", nil)
        fail "Exception is expected"
      rescue => e
        assert_equal "Storage must be of CircuitB::Storage::Base kind", e.message
      end
    end
  
    should "not allow nil-configs" do
      begin
        CircuitB::Fuse.new("name", CircuitB::Storage::Memory.new, nil)
        fail "Exception is expected"
      rescue => e
        assert_equal "Config must be specified", e.message
      end
    end
  end
  
  context "operation" do
    setup do
      @fuse = CircuitB::Fuse.new("name", CircuitB::Storage::Memory.new, :allowed_failures => 1, :cool_off_period => 60)
    end
    
    should "open when the allowed failures reached" do
      assert !@fuse.open?
      do_failure(@fuse)
      assert @fuse.open?
    end
  
    should "reset the failures counter when the attempt succeeds" do
      @fuse = CircuitB::Fuse.new("name", CircuitB::Storage::Memory.new, :allowed_failures => 2)

      do_failure(@fuse)
      assert_equal 1, @fuse.failures
      
      @fuse.wrap do
        # Successful code
      end
      
      assert_equal 0, @fuse.failures
    end
  
    should "fail fast when open" do
      # Open the fuse and verify it's open
      do_failure(@fuse)
      assert @fuse.open?
    
      begin
        @fuse.wrap do
          fail "Must not execute as fail-fast exception is expected"
        end
      rescue => e
        assert e.is_a?(CircuitB::FastFailure), "Wrong exception: #{e.inspect}"
      end
    end
    
    should "close after the cooling period" do
      do_failure(@fuse)

      Timecop.travel(Time.now + @fuse.config[:cool_off_period] + 1) do
        @fuse.send(:close_if_cooled_off)
        
        assert !@fuse.open?
        assert_equal 0, @fuse.failures
      end
    end
    
    should "not count fast failure as an error" do
      do_failure(@fuse)

      # Get the fast failure
      Timecop.travel(Time.now + @fuse.config[:cool_off_period] / 2) do
        begin
          do_failure(@fuse, true)
          fail "Fast failure is expected"
        rescue CircuitB::FastFailure => e
          # Expected
        end
      end

      # The above fast failure should not affect the cooling off schedule
      Timecop.travel(Time.now + @fuse.config[:cool_off_period] + 1) do
        @fuse.send(:close_if_cooled_off)
        assert !@fuse.open?
      end
    end
  end
  
  def do_failure(fuse, rethrow = false)
    begin
      @fuse.wrap do
        raise "Exceptional code"
      end
    rescue => e
      raise e if rethrow
    end
  end
end