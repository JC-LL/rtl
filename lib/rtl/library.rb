require_relative "circuit"

module RTL

  class UnaryGate < Circuit
    def initialize
      name=self.class.to_s.split("::").last
      super(name)
      add Port.new(:in,"i")
      add Port.new(:out,"f")
    end
  end

  class BinaryGate < Circuit
    def initialize
      name=self.class.to_s.split("::").last
      super(name)
      add Port.new(:in,"i1")
      add Port.new(:in,"i2")
      add Port.new(:out,"f")
    end
  end

  class Not < UnaryGate
  end

  class Or < BinaryGate
  end

  class And < BinaryGate
  end

  class Nand < BinaryGate
  end

  class Nor < BinaryGate
  end

  class Xor < BinaryGate
  end

  class Reg < Circuit
    def initialize
      name="Reg"
      super(name)
      add Port.new(:in ,"d")
      add Port.new(:out,"q")
      @color="darkorange"
    end
  end

  class Mux < Circuit
    attr_accessor :arity
    def initialize
      name="Mux"
      super(name)
      @arity=0
      add Port.new(:in,"i0")
      add Port.new(:in,"i1")
      super.add Port.new(:in,"sel")
      super.add Port.new(:out,"f")
    end

    def add port
      @arity+=1
      super port
    end
  end

  class Add < BinaryGate
  end

  class Sub < BinaryGate
  end

  class Mul < BinaryGate
  end

  class Div < BinaryGate
  end

  class Rem < BinaryGate
  end

end
