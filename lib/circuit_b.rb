require "circuit_b/fuse"
require "circuit_b/configuration"
require "circuit_b/storage"

module CircuitB
  
  class FastFailure < StandardError; end
  
  def self.configure(&block)
    block.call(configuration)
  end
  
  def self.configuration
    @configuration ||= CircuitB::Configuration.new
  end
  
  def self.reset_configuration
    @configuration = nil
  end
  
  def self.fuse(name, &block)
    raise "Fuse with the name '#{name}' is not registered" unless fuse = configuration.fuses[name]
    
    if block
      return fuse.wrap(&block)
    else
      return fuse
    end
  end
end

def CircuitB(fuse_name, &block)
  CircuitB.fuse(fuse_name, &block)
end