VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/crcverify/_behavioral.var: ../../vhdl/crcverify.vhd
	$(VHDLC) ../../vhdl/crcverify.vhd

$(WORKDIR)/crc16_combinational/_behavioral.var: ../../vhdl/crcverify.vhd ../../vhdl/crc16_combinational.vhd
	$(VHDLC) ../../vhdl/crc16_combinational.vhd

$(WORKDIR)/crc_combinational/_behavioral.var: ../../vhdl/crcverify.vhd ../../vhdl/crc16_combinational.vhd ../../vhdl/crc_combinational.vhd
	$(VHDLC) ../../vhdl/crc_combinational.vhd

hw: $(WORKDIR)/crcverify/_behavioral.var $(WORKDIR)/crc16_combinational/_behavioral.var $(WORKDIR)/crc_combinational/_behavioral.var 

comp: 

$(WORKDIR)/crcverifytest/_behavioral.var: crcverifytest.vhd
	$(VHDLC) crcverifytest.vhd

sim: $(WORKDIR)/crcverifytest/_behavioral.var 
runsim: all
	$(VHDLS) crcverifytest


clean:
	rm -Rf $(WORKDIR)$

