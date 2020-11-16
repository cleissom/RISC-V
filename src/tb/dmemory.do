set COMPONENT dmemory

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
add wave -bin -label mem_write /mem_write
add wave -bin -label mem_read /mem_read
add wave -hex -label addr /addr
add wave -hex -label write_data /write_data

add wave -height 15 -divider "Outputs"
add wave -hex -label read_data /read_data

add wave -height 15 -divider "Internal"
add wave -hex -color lightblue -label ram /dut/ram

run 100ns

wave zoomfull
#write wave wave.ps