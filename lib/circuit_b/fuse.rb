require 'circuit_b/storage/base'

module CircuitB
  class Fuse

    attr_reader :config

    def initialize(name, state_storage, config)
      raise "Name must be specified" if name.nil?
      raise "Storage must be specified" if state_storage.nil?
      raise "Storage must be of CircuitB::Storage::Base kind" unless state_storage.kind_of?(CircuitB::Storage::Base)
      raise "Config must be specified" if config.nil?
      
      @name          = name
      @state_storage = state_storage
      @config        = config
    end

    def wrap(&block)
      close_if_cooled_off if open?
      raise CircuitB::FastFailure if open?
      
      begin
        block.call

        put(:failures, 0)
      rescue => e
        # Save the time of the last failure
        put(:last_failure_at, Time.now.to_i)
      
        # Increment the number of failures and open if the limit has been reached
        failures = inc(:failures)
        open if failures >= @config[:allowed_failures]
      
        # Re-raise the original exception
        raise e
      end
    end
    
    def open?
      get(:state) == :open
    end

    def failures
      get(:failures)
    end
    
    private

    def close_if_cooled_off
      if Time.now.to_i - get(:last_failure_at).to_i > config[:cool_off_period]
        put(:state, :closed)
        put(:failures, 0)
      end
    end
    
    # Open the fuse
    def open
      put(:state, :open)
    end
    
    def get(field)
      @state_storage.get(@name, field)
    end
    
    def put(field, value)
      @state_storage.put(@name, field, value)
    end
    
    def inc(field)
      @state_storage.inc(@name, field)
    end
  end
end