require 'circuit_b/storage/base'
require 'redis'

module CircuitB
  module Storage
    class RailsCache < Base
      def initialize
        @cache = ::Rails.cache
      end

      def put(fuse_name, field, value)
        @cache.write(key(fuse_name, field), value)
      end

      def get(fuse_name, field)
        @cache.read(key(fuse_name, field))
      end

      def inc(fuse_name, field)
        @cache.increment(key(fuse_name, field))
      end

      private

      def key(fuse_name, field)
        "circuit_b:#{fuse_name}:#{field}"
      end
    end
  end
end
