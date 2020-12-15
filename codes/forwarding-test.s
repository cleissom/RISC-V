li s0, 1
li s1, 2
li s2, 3
li s4, 5
li s5, 7

add t0, x0, s0
add t0, t0, s1
add t0, t0, s2
add t0, t0, s3
add t0, t0, s4
nop
add t0, t0, s5

# Valor final no t0/x5 = 0x12