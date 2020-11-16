set COMPONENT registers

vlib work
vcom constants.vhd
vcom $COMPONENT\.vhd
vcom tb/$COMPONENT\_tb.vhd

vsim -t ns work.$COMPONENT\_tb

view wave

# -radix: bin, hex, dec, ascii
# -label: nome da forma de onda

add wave -height 15 -divider "Inputs"
add wave -bin -color yellow -label clk /clk
add wave -hex -label read_reg1 /read_reg1
add wave -hex -label read_reg2 /read_reg2
add wave -hex -label write_reg /write_reg
add wave -bin -label reg_write /reg_write
add wave -hex -label write_data /write_data

add wave -height 15 -divider "Outputs"
add wave -hex -label read_data1 /read_data1
add wave -hex -label read_data2 /read_data2

add wave -height 15 -divider "Internal"
add wave -hex -color lightblue -label registers /dut/registers

run 50ns

wave zoomfull
#write wave wave.ps