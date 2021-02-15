require_relative 'graph'
require_relative 'vector'


  class Fdgd

    attr_accessor :graph
    attr_accessor :stop

    def initialize graph=nil
      puts "FDGD: force-directed graph drawer"
      @graph=graph
      @l0=80
      @c1=30
      @epsilon=10
      @damping=0.92
      @timestep=0.1
      @stop=false
    end

    def dist a,b
      Math.sqrt((a.x - b.x)**2 + (a.y - b.y)**2)
    end

    def angle a,b
      if dist(a,b)!=0
        if b.x > a.x
          angle = Math.asin((b.y-a.y)/dist(a,b))
        else
          angle = Math::PI - Math.asin((b.y-a.y)/dist(a,b))
        end
      else
        angle =0
      end
      return angle
    end

    def coulomb_repulsion a,b
      angle = angle(a,b)
      dab = dist(a,b)
      c= -0.2*(a.radius*b.radius)/Math.sqrt(dab)
      [c*Math.cos(angle),c*Math.sin(angle)]
    end

    def sign_minus(a,b)
      a>b ? 1 : -1
    end

    def hooke_attraction a,b #,c1=10#,l0=40
      angle = angle(a,b)
      dab = dist(a,b)
      c = @c1*Math.log((dab-@l0).abs)*sign_minus(dab,@l0)
      [c*Math.cos(angle),c*Math.sin(angle)]
    end

    def run iter=2
      if @graph
        Thread.new do
          step = 0
          total_kinetic_energy=1000
          next_pos={}
          next_speed={}
          until total_kinetic_energy < @epsilon or step==iter do

            step+=1
            total_kinetic_energy = 0

            for node in graph.nodes
              net_force = Vector.new(0, 0)

              for other in graph.nodes-[node]
                rep = coulomb_repulsion( node, other)
                net_force += rep
              end

              for edge in graph.edges.select{|e| e.source==node or e.sink==node}
                other = edge.sink==node ? edge.source : edge.sink
                attr = hooke_attraction(node, other) #, c1=30,@l0)
                net_force += attr
              end

              # without damping, it moves forever
              speed = (node.speed + net_force.scale(@timestep)).scale(@damping)
              next_pos[node.id]   = node.pos + speed.scale(@timestep)
              next_speed[node.id] = speed
              total_kinetic_energy += node.radius * speed.squared
            end

            #puts total_kinetic_energy
            yield if block_given?
            #update nodes position
            for node in graph.nodes
              unless node.fixed.x
                node.pos.x = next_pos[node.id].x
                node.speed.x = next_speed[node.id].x
              end
              unless node.fixed.y
                node.pos.y = next_pos[node.id].y
                node.speed.y = next_speed[node.id].y
              end
            end
            break if @stop
          end
          puts "algorithm end"
          puts "reached epsilon" if total_kinetic_energy < @epsilon
          puts "reached max iterations" if step==iter
        end #thread
      end
    end
  end
