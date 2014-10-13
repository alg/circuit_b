require 'circuit_b/storage/base'
require 'redis'

module CircuitB
  module Storage
    class RailsCache < Base
      def initialize
        @cache = ::Rails.cache
      end

      def put(fuse_name, field, value)
        value if @cache.write(key(fuse_name, field), value)
      end

      def get(fuse_name, field)
        @cache.read(key(fuse_name, field))
      end

      def inc(fuse_name, field)
        k = key(fuse_name, field)
        @cache.write(k, 0) unless @cache.read(k)
        @cache.increment(k)
      end

      private

      def key(fuse_name, field)
        "circuit_b:#{fuse_name}:#{field}"
      end
    end
  end
end
