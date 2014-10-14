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
        cur = @cache.read(k) || 0
        new = cur + 1
        @cache.write(k, new)
        new
      end

      private

      def key(fuse_name, field)
        "circuit_b:#{fuse_name}:#{field}"
      end
    end
  end
end
