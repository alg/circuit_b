module CircuitB
  module Storage
    class Base
      def put(_fuse_name, _field, _value)
        fail 'Unimplemented'
      end

      def get(_fuse_name, _field)
        fail 'Unimplemented'
      end

      def inc(_fuse_name, _field)
        fail 'Unimplemented'
      end
    end
  end
end
