module CircuitB
  module Storage
    class Base
      
      def put(fuse_name, field, value)
        raise "Unimplemented"
      end
      
      def get(fuse_name, field)
        raise "Unimplemented"
      end

      def inc(fuse_name, field)
        raise "Unimplemented"
      end
    end
  end
end