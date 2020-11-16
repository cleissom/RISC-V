# to install ghdl and gtkwave:
#
# sudo apt install gnat
# git clone https://github.com/ghdl/ghdl.git
# cd ghdl-master
# ./configure --prefix=/usr/local
# make
# sudo make install
# sudo apt install gtkwave

VHD_FOLDER = ./src
TB_FOLDER = ./src/tb

GHDL_FLAGS = --ieee=synopsys --warn-no-vital-generic --workdir=simu --work=work -fexplicit

%:
	@ mkdir -p simu
	@ ghdl -i $(GHDL_FLAGS) $(VHD_FOLDER)/constants.vhd $(VHD_FOLDER)/$@.vhd $(TB_FOLDER)/$@_tb.vhd
	@ ghdl -r $(GHDL_FLAGS) $@_tb --assert-level=failure --stop-time=$(time) --vcdgz=$@.vcdgz



%-gui:
	gunzip --stdout $*.vcdgz | gtkwave --vcd




TOP = tb

VHD_SRC = \
	../riscv/core_rv32i/bshifter.vhd \
	../riscv/core_rv32i/alu.vhd \
	../riscv/core_rv32i/reg_bank.vhd \
	../riscv/core_rv32i/control.vhd \
	../riscv/core_rv32i/datapath.vhd \
	../riscv/core_rv32i/int_control.vhd \
	../riscv/core_rv32i/cpu.vhd \
	../devices/controllers/spi_master_slave/spi_master_slave.vhd \
	../devices/controllers/uart/uart.vhd \
	../devices/peripherals/standard_soc.vhd \
	../riscv/sim/boot_ram.vhd \
	../riscv/sim/ram.vhd \
	../riscv/sim/hf-riscv_basic_standard_soc_tb.vhd

PROG_SRC = \
	../riscv/sim/boot.txt \
	../software/code.txt

all:

# Command line simulation using the free ghdl
# run simulation with 'make ghdl time=10ms' to run for 10ms
ghdl:
	@ cp $(PROG_SRC) .
	@ mkdir -p simu
	@ ghdl -i --ieee=synopsys --warn-no-vital-generic --workdir=simu --work=work -fexplicit $(VHD_SRC)
	@ ghdl -r --ieee=synopsys --warn-no-vital-generic --workdir=simu --work=work -fexplicit $(TOP) --assert-level=failure --stop-time=$(time) --vcdgz=$(TOP).vcdgz


clean-ghdl:
	@ rm -rf simu
	@ rm -f tb
	@ rm -f tb.vcdgz
	@ rm -f *.txt

# Clean all generated files
clean: clean-ghdl
	@ rm -f debug.txt