module RailsProbe
  module Dsl
    def probe(name, identifiers = /.*/, stack = [], path = Rails.root.join("tmp/probes"), &block)
      probe = Probe.new(name, identifiers, stack, path)
      probe.run(&block)
    end

    module_function :probe
  end
end
