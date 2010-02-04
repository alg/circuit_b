require "circuit_b/storage"
require "circuit_b/fuse"

module CircuitB
  class Configuration

    DEFAULT_CONFIG = {
      :log              => true,
      :timeout          => 5, # seconds
      :allowed_failures => 5,
      :cool_off_period  => 10 # seconds
    }
    
    attr_accessor :state_storage
    attr_reader   :default_fuse_config
    attr_reader   :fuses
    
    def initialize
      @state_storage = CircuitB::Storage::Memory.new
      @default_fuse_config = DEFAULT_CONFIG.clone
      @fuses = {}
    end

    # Sets the default fuse configuration. This configuration will be used
    # as the basis for all fuses. You can override the values by providing
    # your own when calling #fuse.
    #
    #   CircuitB.configure do |c|
    #     c.default_fuse_config = {
    #       :on_break         => [ :rails_log, lambda { do_something } ],
		#       :allowed_failures => 2,
		#       :cool_off_period  => 3	# seconds
    #     }
    #   end
    def default_fuse_config=(config)
      @default_fuse_config = DEFAULT_CONFIG.merge(config)
    end
    
    # Adds a fuse with a given name and custom config.
    # If the fuse with the same name is already there, the RuntimeError is raised.
    # The values of the provided configuration are used to override
    # the default configuration that can be set with #default_fuse_config.
    #
    #   CircuitB.configure do |c|
    #     c.fuse "directory-auth", :on_break => lambda { notify_hoptoad(...) }, :allowed_failures => 5
    #     c.fuse "image-resizing", :allowed_failures => 2, :cool_off_period => 30
    #   end
    def fuse(name, config = {})
      raise "Fuse with this name is already registered" if @fuses.include?(name)

      config = @default_fuse_config.merge(config || {})
      @fuses[name] = CircuitB::Fuse.new(name, state_storage, config)
    end
    
  end
end