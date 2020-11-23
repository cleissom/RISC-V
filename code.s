li x1, 3
li x2, 10
sw x1, 0(x0)
sw x2, 4(x0)
lw t0, 0(x0)
add t1, t0, x2
sw t1, 8(x0)

