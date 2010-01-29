require "circuit_b/storage"
require "circuit_b/fuse"

module CircuitB
  class Configuration

    DEFAULT_CONFIG = {
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

    def default_fuse_config=(config)
      @default_fuse_config = DEFAULT_CONFIG.merge(config)
    end
    
    def add_fuse(name, config = {})
      raise "Fuse with this name is already registered" if @fuses.include?(name)

      config = DEFAULT_CONFIG.merge(config || {})
      @fuses[name] = CircuitB::Fuse.new(name, state_storage, config)
    end
    
  end
end