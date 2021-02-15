require_relative 'vector'
require_relative 'json_parser'

class Node
  attr_accessor :id,:pos,:dims,:speed,:fixed,:radius
  def initialize params={}
    puts "creating node #{params}"
    @id    =params["id"]
    @radius=params["radius"] || rand(5..10)
    @pos   =Vector.new *params["pos"]
    @speed =Vector.new *(params["speed"] || [0,0])
    @fixed =Vector.new *(params["fixed"] || [false,false])
    @dims  =Vector.new *(params["dims"]  || [10,5])
  end

  def x=(v)
    @pos[0]=v
  end

  def y=(v)
    @pos[1]=v
  end

  def x
    @pos.first
  end

  def y
    @pos.last
  end

  def print_info
    pp "node #{@id} : pos=#{@pos},dims=#{@dims},v=#{@velocity}"
  end
end

class Edge
  attr_accessor :source,:sink
  def initialize params={}
    unless params.empty?
      @source=params["source"]
      @sink  =params["sink"]
      puts "creating edge #{@source.id}-->#{@sink.id}"
    end
  end
end

class Graph

  attr_accessor :nodes,:id,:edges,:map

  def initialize id=nil,nodes=[],edges=[]
    @id=id
    @nodes,@edges=nodes,edges
  end

  def self.read_file filename
    Parser.new.parse filename
  end

  def write_file filename
    json=Code.new
    json << "{"
    json.indent=2
    json << "\"id\" : \"#{id}\","
    json << "\"nodes\" : ["
    json.indent=4
    nodes.each{|node| json << json_node(node)}
    json.indent=2
    json << "],"
    json << "\"edges\" : ["
    json.indent=4
    edges.each{|edge| json << json_edge(edge)}
    json.indent=2
    json << "]"
    json.indent=0
    json << "}"
    code=json.finalize
    code.gsub!(/\,\s*\]/,']')
    json=Code.new(code)
    json.save_as filename
  end

  def json_node node
    fixed=node.fixed.to_s
    "{\"id\":\"#{node.id}\",\"pos\":#{node.pos.to_s},\"speed\":#{node.speed.to_s},\"fixed\":#{fixed}},"
  end

  def json_edge edge
    "{\"source\":\"#{edge.source.id}\",\"sink\":\"#{edge.sink.id}\"},"
  end

  def self.random(nbVertex,maxNbEdgesPerVertex=2)
    nodes=(1..nbVertex).map{|i|
      h={
        "id" => "#{i}",
        "pos"=> [rand(1000),rand(1000)]
      }
      Node.new(h)
    }
    edges=[]
    nodes.each_with_index do |node,idx|
      nb_edges=rand(0..maxNbEdgesPerVertex)
      nb_edges.times do
        edge=Edge.new
        edge.source=node
        edge.sink=sink=nodes.sample
        (edges << edge) unless nodes.index(sink)==idx
      end
    end
    Graph.new("g",nodes,edges)
  end

  def shuffle range=0..800
    @nodes.each do |node|
      nx,ny=rand(range),rand(range)
      node.pos=Vector.new(nx,ny)
    end
  end

  def print_info
    puts "graph info".center(40,"=")
    puts "#vertices".ljust(30,'.')+nodes.size.to_s
    puts "#edges".ljust(30,'.')+edges.size.to_s

    puts "nodes".center(40,'-')
    nodes.each do |node|
      puts "#{node.id.ljust(10)} #{node.pos.x} #{node.pos.y}"
    end
    puts "edges".center(40,'-')
    edges.each do |edge|
      puts "#{edge.source.id} --> #{edge.sink.id}"
    end
  end

  def self.rand_between min,max
    (min..max).to_a.sample
  end

  def self.random_pos(maxx=800,maxy=600)
    x,y=maxx/2,maxy/2
    [self.rand_between(-x,x),self.rand_between(-y,y)]
  end

  def each_vertex &block
    @nodes.each do |node|
      yield node
    end
  end

  def each_edge &block
    @edges.each do |edge|
      yield edge
    end
  end
end
