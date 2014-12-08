module CircuitB
  module Storage
    class Base
      def put(_fuse_name, _field, _value)
        fail NotImplementedError
      end

      def get(_fuse_name, _field)
        fail NotImplementedError
      end

      def inc(_fuse_name, _field)
        fail NotImplementedError
      end
    end
  end
end
