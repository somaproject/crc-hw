VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/crc_combinational.vhd
	$(VHDLC) ../../vhdl/crc_combinational.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/crc_combinational.vhd ../../vhdl/crc16_combinational.vhd
	$(VHDLC) ../../vhdl/crc16_combinational.vhd

$(WORKDIR)/crcappend/_behavioral.var: ../../vhdl/crc_combinational.vhd ../../vhdl/crc16_combinational.vhd ../../vhdl/crcappend.vhd
	$(VHDLC) ../../vhdl/crcappend.vhd

hw: $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crcappend/_behavioral.var 

comp: 

$(WORKDIR)/crcappendtest/_behavioral.var: crcappendtest.vhd
	$(VHDLC) crcappendtest.vhd

sim: $(WORKDIR)/crcappendtest/_behavioral.var 
runsim: all
	$(VHDLS) crcappendtest


clean:
	rm -Rf $(WORKDIR)$

