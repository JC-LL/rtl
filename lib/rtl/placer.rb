require_relative "fdgd"
require_relative 'code'

module RTL

  class Placer

    attr_accessor :circuit

    def place circuit
      puts "placing '#{circuit.name}'"
      @circuit=circuit
      puts "creating p&r graph"
      nodes=gen_pnr_nodes(circuit)
      edges=gen_pnr_edges(circuit)
      graph=Graph.new(circuit.name,nodes,edges)
      graph.print_info
      drawer=Fdgd.new(graph)
      drawer.run 100
      puts "final placement".center(40,'=')
      graph.write_file "#{circuit.name}.json"
      gen_svg graph
    end


    def gen_pnr_nodes circuit
      nodes=[]
      @sym={} # internal references for p&r
      @map={} # link to RTL::Circuit objects
      circuit.inputs.each_with_index do |port,idx|
        id=port.object_id.to_s
        dy=600.0/circuit.inputs.size
        params={"id"    => id,
                "pos"   => [10,idx*dy],
                "fixed" => [true,false],
        }
        nodes << node=Node.new(params)
        @sym[id]=node
        @map[node]=port
      end
      circuit.outputs.each_with_index do |port,idx|
        id=port.object_id.to_s
        dy=600.0/circuit.outputs.size
        params={"id"    => id,
                "pos"   => [500,dy*idx],
                "fixed" => [true,false],
        }
        nodes << node=Node.new(params)
        @sym[id]=node
        @map[node]=port
      end
      circuit.signals.each do |port|
        id=port.object_id.to_s
        params={"id"    => id,
                "pos"   => [rand(600),rand(600)]
        }
        nodes << node=Node.new(params)
        @sym[id]=node
        @map[node]=port
      end
      circuit.components.each do |comp|
        id=comp.object_id.to_s
        params={"id"    => id,
                "pos"   => [rand(300),rand(300)],
        }
        nodes << node=Node.new(params)
        @sym[id]=node
        @map[node]=comp
      end
      nodes
    end

    def gen_pnr_edges circuit
      edges=[]
      circuit.inputs.each do |input|
        input.fanout.each do |wire|
          psource=wire.source
          if psource.circuit==circuit #psink is a port of current circuit
            source=psource
          else
            source=psource.circuit # one of the components
          end
          psink=wire.sink
          if psink.circuit==circuit #psink is a port of current circuit
            sink=psink
          else
            sink=psink.circuit # one of the components
          end
          id_source=source.object_id.to_s
          id_sink  =sink.object_id.to_s
          node_source=@sym[id_source]
          node_sink=@sym[id_sink]
          params={"source"    => node_source,
                  "sink"      => node_sink
          }
          edges << Edge.new(params)
        end
      end
      circuit.signals.each do |sig|
        sig.fanout.each do |wire|
          psource=wire.source
          if psource.circuit==circuit #psink is a port of current circuit
            source=psource
          else
            source=psource.circuit # one of the components
          end
          psink=wire.sink
          if psink.circuit==circuit #psink is a port of current circuit
            sink=psink
          else
            sink=psink.circuit # one of the components
          end
          id_source=source.object_id.to_s
          id_sink  =sink.object_id.to_s
          node_source=@sym[id_source]
          node_sink=@sym[id_sink]
          params={"source"    => node_source,
                  "sink"      => node_sink
          }
          edges << Edge.new(params)
        end
      end
      circuit.components.each do |comp|
        comp.outputs.each do |output|
          output.fanout.each do |wire|
            psource=wire.source
            if psource.circuit==circuit #psink is a port of current circuit
              source=psource
            else
              source=psource.circuit # one of the components
            end
            psink=wire.sink
            if psink.circuit==circuit #psink is a port of current circuit
              sink=psink
            else
              sink=psink.circuit # one of the components
            end
            id_source=source.object_id.to_s
            id_sink  =sink.object_id.to_s
            node_source=@sym[id_source]
            node_sink=@sym[id_sink]
            params={"source"    => node_source,
                    "sink"      => node_sink
            }
            edges << Edge.new(params)
          end
        end
      end
      edges
    end

    SVG_ELEMENT={
        "and"  => "and2",
        "nand" => "nand2",
        "or"   => "or2",
        "nor"  => "nor2",
        "xor"  => "xor2",
        "not"  => "not",
    }
    def gen_svg graph
      svg=Code.new
      svg << "<svg width=\"600\" height=\"300\""
      svg << "     xmlns=\"http://www.w3.org/2000/svg\""
      svg << "     xmlns:xlink=\"http://www.w3.org/1999/xlink\">"
      svg << IO.read("/home/jcll/JCLL/dev/EDA-ESL/rtl/lib/rtl/def_gates.svg")
      graph.nodes.each do |node|
        circuit=@map[node]
        klass=circuit.class.to_s.split("::").last.downcase
        element=SVG_ELEMENT[klass] || "not"
        pos=node.pos
        x,y=pos.x,pos.y
        svg << "<use xlink:href=\"##{element}\"  x=\"#{x}\" y=\"#{y}\"/>"
      end
      svg << "</svg>"
      filename="#{circuit.name}_pnr.svg"
      svg.save_as filename
    end
  end
end
