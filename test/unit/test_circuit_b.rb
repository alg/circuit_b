require 'circuit_b'
require 'circuit_b/configuration'
require 'circuit_b/storage'

class TestCircuitB < Minitest::Spec
  context 'configuration' do
    should 'accept configuration paramters' do
      CircuitB.configure do |config|
        config.state_storage = CircuitB::Storage::Memory.new

        config.default_fuse_config = {
          allowed_failures: 2,
          cool_off_period: 3  # seconds
        }

        config.fuse('mail', allowed_failures: 5,
                            cool_off_period: 10)
      end
    end

    should 'return configuration' do
      config = CircuitB.configuration
      assert config.is_a?(CircuitB::Configuration)
    end
  end

  context 'using fuses to protect code' do
    setup do
      begin
        CircuitB::Storage::Redis.new.get('dummy', 'field')
      rescue Errno::ECONNREFUSED
        raise 'Please start Redis on default port'
      end

      CircuitB.reset_configuration
      CircuitB.configure do |c|
        c.state_storage = CircuitB::Storage::Redis.new
        c.fuse 'fuse_name', allowed_failures: 1, cool_off_period: 10
      end
      CircuitB('fuse_name').reset
    end

    should 'let wrap the code with fuse' do
      executed = false
      CircuitB('fuse_name') do
        # Some lengthy and potentially failing operation
        executed = true
      end

      assert executed, "Code wasn't executed"
    end

    should 'pass the execution result back' do
      result = CircuitB('fuse_name') do
        'result'
      end
      assert_equal 'result', result
    end

    should "error out if the fuse doesn't exist" do
      begin
        CircuitB('non_existent_fuse') do
          # Will never be executed
          fail 'Should never be executed'
        end
      rescue => e
        assert_equal "Fuse with the name 'non_existent_fuse' is not registered", e.message
      end
    end

    should "pass the error when it's raised by the code" do
      begin
        CircuitB('fuse_name') do
          fail 'App error'
        end
        fail 'App error should be raised'
      rescue => e
        assert_equal 'App error', e.message
      end
    end

    should 'return the fuse if no block is given' do
      assert CircuitB('fuse_name').is_a?(CircuitB::Fuse)
    end
  end
end
