require_relative './lib/rtl/version'

Gem::Specification.new do |s|
  s.name        = 'rtl_circuit'
  s.version     = RTL::VERSION
  s.date        = Time.now.strftime('%F')
  s.summary     = "simple digital circuit modeling"
  s.description = "simple digital circuit modeling, with hierarchy and graphviz output"
  s.authors     = ["Jean-Christophe Le Lann"]
  s.email       = 'jean-christophe.le_lann@ensta-bretagne.fr'
  s.files       = [
                   "lib/rtl/code.rb",
                   "lib/rtl/circuit.rb",
                   "lib/rtl/library.rb",
                   "lib/rtl/printer.rb",
                   #--------- p&r stuff
                   "lib/rtl/def_gates.svg",
                   "lib/rtl/placer.rb",
                   "lib/rtl/json_parser.rb",
                   "lib/rtl/vector.rb",
                   "lib/rtl/graph.rb",
                   "lib/rtl/fdgd.rb",
                   "lib/rtl/viewer.rb",
                   "lib/rtl/canvas.rb",
                   "lib/rtl.rb"
                  ]
  s.files += Dir["tests/*/*.rb"]
  s.homepage    = 'http://www.github.com/JC-LL/rtl'
  s.license       = 'GPL-2.0-only'
end
