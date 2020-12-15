VHD_FOLDER = ./src
TB_FOLDER = ./src/tb
SCRIPTS_FOLDER = ./src/scripts
WAVES_FOLDER = ./src/waves
CODES_FOLDER = ./codes

VHD_CONSTANTS = $(VHD_FOLDER)/constants.vhd
VHD_GLOBALS = $(VHD_CONSTANTS)

GHDL_FLAGS = --ieee=synopsys --warn-no-vital-generic --workdir=simu --work=work -fexplicit


imemory_TIME = 50ns
dmemory_TIME = 600ns
regn_TIME = 40ns
registers_TIME = 200ns
alu_TIME = 80ns
datapath_TIME = 30000ns




alu_EXTRA_VHD = $(VHD_FOLDER)/bshifter.vhd

dmemory_EXTRA_VHD = $(VHD_FOLDER)/ram.vhd

datapath_EXTRA_VHD = 	$(VHD_FOLDER)/control.vhd \
			$(VHD_FOLDER)/registers.vhd \
			$(VHD_FOLDER)/ram.vhd \
			$(VHD_FOLDER)/dmemory.vhd \
			$(VHD_FOLDER)/imemory.vhd \
			$(VHD_FOLDER)/bshifter.vhd \
			$(VHD_FOLDER)/alu.vhd \
			$(VHD_FOLDER)/forwarding_unit.vhd \
			$(VHD_FOLDER)/hazard_unit.vhd




code: 
ifdef file
	@ cp $(CODES_FOLDER)/$(file).bin code.bin
	@ cp $(CODES_FOLDER)/$(file).s code.s
	@ hexdump -v -e '4/1 "%02x" "\n"' code.bin > code.txt
else
	@ hexdump -v -e '4/1 "%02x" "\n"' code.bin > code.txt
endif



# Command line simulation using the free ghdl
# run simulation with 'make alu time=10ms' to run for 10ms

%:
	@ mkdir -p simu
	@ ghdl -i $(GHDL_FLAGS) $(VHD_GLOBALS) $($@_EXTRA_VHD) $(VHD_FOLDER)/$@.vhd $(TB_FOLDER)/$@_tb.vhd
	@ ghdl -r $(GHDL_FLAGS) $@_tb --assert-level=failure --stop-time=$($@_TIME) --vcdgz=$@.vcdgz --wave=$@.ghw
	@ mkdir -p $(WAVES_FOLDER)
	#gunzip --stdout $*.vcdgz | gtkwave --vcd $(WAVES_FOLDER)/$*.gtkw
	gtkwave -f $*.ghw $(WAVES_FOLDER)/$*_ghw.gtkw




behavioral:
	@ sed -i 's/imemory(rtl)/imemory(behavioral)/g' $(VHD_FOLDER)/datapath.vhd

synthesis:
	@ sed -i 's/imemory(behavioral)/imemory(rtl)/g' $(VHD_FOLDER)/datapath.vhd

clean-ghdl:
	@ rm -rf simu
	@ rm -f tb
	@ rm -f *.vcdgz
	@ rm -f *.ghw
	@ rm -f *.txt
	@ rm -f *.bin
	@ rm -f *.s

# Clean all generated files
clean: clean-ghdl
	@ rm -f debug.txt
