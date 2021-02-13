require_relative "../lib/rtl"

include RTL

ha=Circuit.new("ha")
ha.add a =Port.new(:in,"a")
ha.add b =Port.new(:in,"b")
ha.add s =Port.new(:out,"s")
ha.add co=Port.new(:out,"co")
ha.add and_=And.new
ha.add xor_=Xor.new

a.connect and_.port_named(:in,"i1")
b.connect and_.port_named(:in,"i2")
a.connect xor_.port_named(:in,"i1")
b.connect xor_.port_named(:in,"i2")
xor_.port_named(:out,"f").connect s
and_.port_named(:out,"f").connect co

fa=Circuit.new("fa")
fa.add a =Port.new(:in,"a")
fa.add b =Port.new(:in,"b")
fa.add ci=Port.new(:in,"ci")
fa.add s= Port.new(:out,"s")
fa.add co=Port.new(:out,"co")

fa.add ha_1=ha.new_instance
fa.add ha_2=ha.new_instance

fa.add or_=Or.new
a.connect  ha_2.port_named(:in,'a')
b.connect  ha_1.port_named(:in,'a')
ci.connect ha_1.port_named(:in,'b')
ha_1.port_named(:out,'s').connect ha_2.port_named(:in,'b')
ha_2.port_named(:out,'co').connect or_.port_named(:in,'i1')
ha_1.port_named(:out,'co').connect or_.port_named(:in,'i2')
or_.port_named(:out,'f').connect fa.port_named(:out,'co')
ha_2.port_named(:out,'s').connect fa.port_named(:out,'s')

printer=Printer.new
printer.print ha
printer.print fa
