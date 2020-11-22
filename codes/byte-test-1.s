li t0, -1
li t1, 5
nop
nop
nop
sw t0, 0(x0)
sb t1, 1(x0)
lw t0, 0(x0)
lb t1, 1(x0)

# Final x5 = 0xFFFF05FF e x6 = 0x05
