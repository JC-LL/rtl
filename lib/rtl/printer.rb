require_relative 'code'

module RTL

  class Printer
    def print circuit
      dot=Code.new
      dot << "digraph G {"
      dot.indent=2
      dot << "graph [rankdir = LR];"
      circuit.components.each do |comp|
        inputs_dot ="{"+comp.ports[:in].collect{|e| "<#{e.name}>#{e.name}"}.join("|")+"}"
        outputs_dot="{"+comp.ports[:out].collect{|e| "<#{e.name}>#{e.name}"}.join("|")+"}"
        color="cadetblue"
        dot << "#{comp.iname}[ shape=record; style=filled ; color=#{color} ; label=\"{ #{inputs_dot}| #{comp.name} | #{outputs_dot} }\"];"
      end
      circuit.ports[:in].each do |p|
        dot << "#{p.name}[shape=cds label=\"#{p.name}\"];"
      end
      circuit.ports[:out].each do |p|
        dot << "#{p.name}[shape=cds label=\"#{p.name}\"];"
      end
      circuit.signals.each do |sig|
        dot << "#{sig.name}[shape=point ; xlabel=\"#{sig.name}\"]; /* sig */"
      end
      circuit.ports[:in].each do |source|
        source.fanout.each do |wire|
          source_name=source.name
          sink=wire.sink
          sink_name=sink.name
          if sink.circuit!=circuit
            sink_name="#{sink.circuit.iname}:#{sink_name}"
          end
          wire_name=wire.name if $verbose
          dot << "#{source_name} -> #{sink_name} [label=\"#{wire_name}\"]/* pin */"
        end
      end
      circuit.signals.each do |sig|
        sig.fanout.each do |wire|
          source_name=sig.name
          sink  =wire.sink
          sink_name=sink.name
          if sink.circuit!=circuit
            sink_name="#{sink.circuit.iname}:#{sink_name}"
          end
          wire_name=wire.name if $verbose
          dot << "#{source_name} -> #{sink_name} [label=\"#{wire_name}\"] /* sig */"
        end
      end

      circuit.components.each do |c|
        c.ports[:out].each do |p|
          p.fanout.each do |wire| #pin
            pout=wire.sink
            c=pout.circuit==circuit ? "#{pout.name}" : "#{pout.circuit.iname}:#{pout.name}"
            if c!=p.circuit.iname+":"+p.name
              wire_name=wire.name if $verbose
              dot << "#{p.circuit.iname}:#{p.name} -> #{c}[label=\"#{wire_name}\"]; /* tag3 */"
            end
          end
        end
      end
      dot.indent=0
      dot << "}"
      dot.save_as "#{circuit.name}.dot",verbose=false
    end
  end
end
