require 'circuit_b/storage/base'
require 'redis'

module CircuitB
  module Storage
    class Redis < Base
      def initialize
        host = ENV['REDIS_HOST'] || 'localhost'
        port = ENV['REDIS_PORT'] || '6379'
        @redis = ::Redis.new(host: host, port: port)
      end

      def put(fuse_name, field, value)
        @redis[key(fuse_name, field)] = value
      end

      def get(fuse_name, field)
        @redis[key(fuse_name, field)]
      end

      def inc(fuse_name, field)
        @redis.incr(key(fuse_name, field))
      end

      private

      def key(fuse_name, field)
        "circuit_b:#{fuse_name}:#{field}"
      end
    end
  end
end
