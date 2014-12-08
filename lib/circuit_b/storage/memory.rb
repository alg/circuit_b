require 'circuit_b/storage/base'

module CircuitB
  module Storage
    class Memory < Base
      def initialize
        @fuse_states = {}
      end

      def put(fuse_name, field, value)
        @fuse_states[fuse_name] ||= {}
        @fuse_states[fuse_name][field.to_sym] = value
      end

      def get(fuse_name, field)
        (@fuse_states[fuse_name] || {})[field.to_sym]
      end

      def inc(fuse_name, field)
        new_val = get(fuse_name, field).to_i + 1
        put(fuse_name, field, new_val)
        new_val
      end
    end
  end
end
