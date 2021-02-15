#require "rtl_circuit"
require_relative "../../../rtl/lib/rtl.rb"

include RTL

top=Circuit.new("top")
top.add a=Port.new(:in,"a")
top.add b=Port.new(:in,"b")
top.add c=Port.new(:in,"c")
top.add d=Port.new(:in,"d")
top.add f=Port.new(:out,"f")
top.add a1=And.new
top.add a2=Or.new
top.add a3=Xor.new
top.add a4=Nand.new
top.add a5=And.new

a.connect a1.port("i1")
b.connect a1.port("i2")
b.connect a2.port("i1")
c.connect a2.port("i2")
c.connect a3.port("i1")
d.connect a3.port("i2")
a2.port("f").connect a4.port("i1")
a3.port("f").connect a4.port("i2")
a1.port("f").connect a5.port("i1")
a4.port("f").connect a5.port("i2")
a5.port("f").connect f
top.to_dot

Placer.new.place top
