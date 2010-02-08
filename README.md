Theory
======

When you are accessing some resource that is known to be unreliable,
it's better to wrap your requests with a circuit breaking logic.
The breaker acts as a fuse. When it senses that all your requests
end up with errors, it breaks the circuit and starts throwing fail-fast
errors instead without even trying to execute the code block in question.
Often it gives enough time for the resource (mail server, directory service,
router etc) to recover and resume normal operation.

After a certain period of time, circuit breaker attempts to restore
the link and, if it sees that the problem is still there, it breaks it
again.


Installation
============

	gem install circuit_b


Configuration
=============

	CircuitB.configure do |c|

		# Configure the storage that will be used to store the
		# state of the fuses across multiple invocations.
		# There are Memory- and Redis-based stores:
		#   - Memore store is good when you don't have
		#     several threads working with the same fuse,
		#     like in Rails or other multi-threaded environments.
		#   - Redis store is good for shared multi-threaded
		#     environments.
		c.state_storage = CircuitB::Storage::Redis.new

		# Configure the default fuse configuration that will be
		# used as the basis when you add your custom fuses. You
		# can specify only the parameters you want to override then.
		c.default_fuse_config = {
			:on_break         => [ :rails_log, lambda { do_something } ],
			:allowed_failures => 2,
			:cool_off_period  => 3	# seconds
			:timeout          => 3  # seconds, defaults to 5
		}

		# Adds a fuse named "shipping" that is configured to tolerate
		# 5 failures before opening. After the cool off period
		# of 60 seconds it will close again. During the cool-off
		# time it will be raising FastFailure's without even
		# executing the code to protect the system from overload.
		c.fuse "shipping", :allowed_failures => 5, :cool_off_period => 60

	end


Available storages
==================

In order to share the state between co-named fuses, one needs to use
the storage of the correct type. There are currently two storages for
the fuse state that you can use:

* _CircuitB::Storage::Memory_ -- the simplest memory-based storage.
	Ideal for the single-threaded situations.

* _CircuitB::Storage::Redis_ -- Redis-based storage. Well-suited
	for distributed setups (like multiple workers in Rails and alike)
	and acts like a simple IPC.


Acting on Fuse Breaks
=====================

When the ciruit is broken, meaning that your wrapped code has produced
so many errors that we had to isolate it, the fuse opens and starts to
fail fast. You may want to act in one way or another when it happens.
There's a fuse configuration option `on_break` that accepts one or more
elements describing what you want to do.

*Logging.* One of the common steps is to log the event. There's a
standard logging feature (`:rails_log`) that writes a message to the
default Rails log. If you don't use Rails, you can use the next feature
to take care of your logging.

	config.fuse "test", :on_break => :rails_log

*Handling.* If you want to handle the event in some custom way, you
can provide a `Proc` that will be executed upon event. One common case
is to write to the log. 

	config.fuse "test", :on_break => lambda { |fuse| puts "Fuse #{fuse.name} has just broke the circuit" }

To specify more than one handler, you can use an array:

	config.fuse "test", :on_break => [ :rails_log, lambda { ... }, lambda { ... } ]


Code execution timeouts
=======================

To protect your code from executing for too long, fuses in CircuitB can
execute it wrapped into the timeout statements. All you have to do is
to configure a fuse to use timeouts logic, like this (to allow 5 second for
wrapped code execution):

	config.fuse "test", :timeout => 2

To disable timeouts (which isn't a great idea), use `:timeout => false`.

By default, all fuses use 5 second timeouts.


Usage
=====

Every time you want to protect a piece of code, you do this:

	CircuitB("shipping") do
		# Attempting to estimate shipping
	end

or, if you need the value back:

	shipping_cost = CircuitB("shipping") do
		get_shipping_estimate(...)
	end

Note, that in order to use "shipping" fuse you need to add it to your
configuration first (see above).

You can use fuses in any number of places, but since the state is
shared across all fuses with the same name, make sure you use them
for the same purpose, or better yet, refactor your code to have
it all in one place.


To Do
=====

* half-open state to open back faster if the problem still exists
* incrementing cool-off period on recurring errors (in half-open state)
* CouchDB storage
* Memcached storage
* passing storage configuration through the initializer


License
=======

Circuit Breaker is Copyright © 2010 [Aleksey Gureiev](mailto:spyromus@noizeramp.com).
It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.