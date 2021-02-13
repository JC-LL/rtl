module RTL

  class Circuit
    attr_accessor :name
    attr_accessor :iname
    attr_accessor :ports
    attr_accessor :components
    attr_accessor :father
    attr_accessor :signals
    attr_accessor :properties

    @@id=-1

    def initialize name=nil
      @name=name
      @iname="#{name}_#{@@id+=1}"
      @ports={in:[],out:[]}
      @signals=[]
      @components=[]
      @properties={}
    end

    def add element
      port=circuit=sig=element
      case element
      when Sig
        @signals<< sig
        sig.circuit=self
      when Port
        @ports[port.dir] << port
        port.circuit=self
      when Circuit
        @components << circuit
        circuit.father=self
      else
        raise "ERROR : when adding '#{element}'"
      end
    end

    def port_named dir,name
      @ports[dir].find{|p| p.name==name}
    end

    def component_named name
      @components.find{|comp| comp.iname==name}
    end

    def inputs
      @ports[:in]
    end

    def outputs
      @ports[:out]
    end

    def new_instance
      @@clone_id||={}
      @@clone_id[name]||=-1
      @@clone_id[name]+=1
      clone=Marshal.load(Marshal.dump(self))
      clone.iname=self.name+"_#{@@clone_id[name]}"
      clone
    end

    def make_lib
      filename="#{name}.lib"
      File.open(filename,'w') do |f|
        f.puts Marshal.dump(self)
      end
    end

    def to_dot
      Printer.new.print self
    end
  end

  class Port
    attr_accessor :dir
    attr_accessor :name
    attr_accessor :circuit
    attr_accessor :fanout
    attr_accessor :properties
    def initialize dir,name
      @dir=dir
      @name=name
      @fanout=[]
      @properties={}
    end

    def connect port
      puts "connecting #{self.name}-> #{port.name}" if $verbose
      @fanout << Wire.new(self,port)
    end

    def type=(t)
      @properties[:type]=t
    end

    def type
      @properties[:type]
    end
  end

  class Sig < Port
    def initialize name
      super(:out,name)
    end
  end

  class Wire
    @@id=-1
    attr_accessor :name
    attr_accessor :source,:sink
    attr_accessor :properties
    def initialize source,sink
      @name="w_#{@@id+=1}"
      @source=source
      @sink=sink
      @properties={}
    end
  end
end
