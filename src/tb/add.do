set COMPONENT add

vlib work
vcom constants.vhd
vcom $COMPONENT\.vhd
vcom tb/$COMPONENT\_tb.vhd

vsim -t ns work.$COMPONENT\_tb

view wave

# -radix: bin, hex, dec, ascii
# -label: nome da forma de onda

add wave -height 15 -divider "Inputs"
add wave -hex -label data1 /data1
add wave -hex -label data2 /data2

add wave -height 15 -divider "Outputs"
add wave -hex -label output /output

run 50ns

wave zoomfull
#write wave wave.ps