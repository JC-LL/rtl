#require "rtl_circuit"
require_relative "../../../rtl/lib/rtl.rb"

include RTL

top=Circuit.new("top")
top.add a=Port.new(:in,"a")
top.add b=Port.new(:in,"b")
top.add f=Port.new(:out,"f")
top.add g1=And.new
top.add g2=Xor.new

a.connect g1.port("i1")
b.connect g1.port("i2")
b.connect g2.port("i2")
g1.port("f").connect g2.port("i1")
g2.port("f").connect f
top.to_dot

Placer.new.place top
