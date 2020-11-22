li a0, 5
li a1, 3
jal func
mv t0, a0
sw t0 0(x0)
j end

func:
	mv t0, a0
	nop
	nop
	loop:
	beq x0, t0, end_loop
	add t1, t1, a1
	addi t0, t0, -1
	j loop
	end_loop:
	mv a0, t1
	jr x1

end:

# Final x5 = 0x0F
