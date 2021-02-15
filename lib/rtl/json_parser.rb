require "json"

require_relative 'graph'

class Parser
  def parse filename
    puts "parsing '#{filename}'"
    json=JSON.parse(IO.read(filename))
    gen_graph json
  end

  def gen_graph json
    @sym={}
    graph=Graph.new
    json.each do |key,val|
      case key
      when "id"
        graph.id=val
      when "nodes"
        graph.nodes=gen_nodes(val)
      when "edges"
        graph.edges=gen_edges(val)
      end
    end
    return graph
  end

  def gen_nodes json
    json.map{|j| gen_node(j)}
  end

  def gen_node json
    node=Node.new(json)
    @sym[node.id]=node
    node
  end

  def gen_edges json
    json.map{|j| gen_edge(j)}
  end

  def gen_edge json
    a=json.map{|k,v| {k => @sym[v]}}
    Edge.new(a.inject(:merge))
  end

end

#pp Parser.new.parse("line.sexp")
