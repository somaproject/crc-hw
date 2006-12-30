VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/crc16_combinational.vhd
	$(VHDLC) ../../vhdl/crc16_combinational.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/crc16_combinational.vhd ../../vhdl/crc_combinational.vhd
	$(VHDLC) ../../vhdl/crc_combinational.vhd

$(WORKDIR)/crcverify/_behavioral.var: ../../vhdl/crc16_combinational.vhd ../../vhdl/crc_combinational.vhd ../../vhdl/crcverify.vhd
	$(VHDLC) ../../vhdl/crcverify.vhd

$(WORKDIR)/crcappend/_behavioral.var: ../../vhdl/crc16_combinational.vhd ../../vhdl/crc_combinational.vhd ../../vhdl/crcverify.vhd ../../vhdl/crcappend.vhd
	$(VHDLC) ../../vhdl/crcappend.vhd

hw: $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crc_combinational/_behavioral.var $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/crcappend/_behavioral.var 

comp: 

$(WORKDIR)/unifiedtest/_behavioral.var: unifiedtest.vhd
	$(VHDLC) unifiedtest.vhd

sim: $(WORKDIR)/unifiedtest/_behavioral.var 
runsim: all
	$(VHDLS) unifiedtest


clean:
	rm -Rf $(WORKDIR)$

