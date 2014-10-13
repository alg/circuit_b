require 'active_support'

# This is hacks but required to test Rails cache backend correctly
module Rails
  class << self
    attr_accessor :cache
  end
end



module CircuitB
  module Storage
    storage_ops = -> do
      describe 'storage operations' do
        it 'stores fuse states with put and return value' do
          val = @store.put('fuse_name', 'field', 'value')
          assert_equal val, 'value'
        end

        it 'gets fuse states with get' do
          val = @store.put('fuse_name', 'field', 'value')
          val = @store.get('fuse_name', 'field')
          assert_equal val, 'value'
        end

        it 'increments fuses with inc and return counter' do
          val = @store.inc('fuse_name', 'inc_field')
          assert_equal val, 1
        end
      end
    end

    describe 'memory store' do
      before do
        @store = Memory.new
      end
      storage_ops.call
    end

    describe 'redis store' do
      before do
        @store = Redis.new
      end
      storage_ops.call
    end

    describe 'rails cache store' do
      before do
        ::Rails.cache = ActiveSupport::Cache.lookup_store :memory_store
        @store = RailsCache.new
      end
      storage_ops.call
    end
  end
end
