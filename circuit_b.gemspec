spec = Gem::Specification.new do |s|
  s.name             = 'circuit_b'
  s.version          = '1.1'
  s.summary          = 'Distributed circuit breaker'
  s.description      = 'Classic circuit breaker to protect resources from being accessed over and over while in pain.'
  s.files            = Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_path     = 'lib'
  s.has_rdoc         = true
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options     << '--title' <<  'CircuitB - Distributed circuit breaker'
  s.author           = "Aleksey Gureiev"
  s.email            = "spyromus@noizeramp.com"
  s.homepage         = "http://github.com/alg/circuit_b"
end