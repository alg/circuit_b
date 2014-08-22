require 'circuit_b/storage/base'

module CircuitB
  class Fuse

    # Maximum time the handler is allowed to execute
    DEFAULT_BREAK_HANDLER_TIMEOUT = 5

    # Standard handlers that can be refered by their names
    STANDARD_HANDLERS = {
      :rails_log => lambda do |fuse|
        Rails.logger.error("CircuitB: Fuse '#{fuse.name}' has broken")
      end
    }

    attr_reader :name, :config
    attr_accessor :break_handler_timeout

    def initialize(name, state_storage, config)
      raise "Name must be specified" if name.nil?
      raise "Storage must be specified" if state_storage.nil?
      raise "Storage must be of CircuitB::Storage::Base kind" unless state_storage.kind_of?(CircuitB::Storage::Base)
      raise "Config must be specified" if config.nil?

      @name          = name
      @state_storage = state_storage
      @config        = config

      @break_handler_timeout = DEFAULT_BREAK_HANDLER_TIMEOUT
    end

    def wrap(&block)
      close_if_cooled_off if open?
      raise CircuitB::FastFailure if open?

      begin
        result = nil

        if @config[:timeout] && @config[:timeout].to_f > 0
          Timeout::timeout(@config[:timeout].to_f) { result = block.call }
        else
          result = block.call
        end

        put(:failures, 0)

        return result
      rescue Exception => e
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
      # get(:state) == :open # redis store returns strings not symbols
      get(:state) && get(:state).to_sym == :open
    end

    def failures
      get(:failures)
    end

    def reset
      put(:state, :closed)
      put(:failures, 0)
      put(:last_failure_at, nil)
    end

    private

    def close_if_cooled_off
      if Time.now.to_i - get(:last_failure_at).to_i > config[:cool_off_period]
        put(:state, :closed)
        put(:failures, 0)

        Rails.logger.info("Opening fuse #{@name}")
      end
    end

    # Open the fuse
    def open
      put(:state, :open)

      if config[:on_break]
        require 'timeout'

        handlers = [ config[:on_break] ].flatten.map { |handler| (handler.is_a?(Symbol) ? STANDARD_HANDLERS[handler] : handler) }.compact

        handlers.each do |handler|
          begin
            Timeout::timeout(@break_handler_timeout) {
              handler.call(self)
            }
          rescue Timeout::Error
            # We ignore handler timeouts
          rescue
            # We ignore handler errors
          end
        end
      end
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