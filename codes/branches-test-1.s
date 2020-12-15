li s0, 0	# s0 <= all loops Counter
li s1, 0	# s1 <= loop counter
li s2, 4	# s2 <= limit N

equal:
	beq s1, s2, less_than
	addi s0, s0, 1
	addi s1, s1, 1
	j equal

less_than:
	blt s1, s2, greater_than_equal
	addi s0, s0, 1
	addi s1, s1, -2
	j less_than


greater_than_equal:
	bge s1, s2, not_equal
	addi s0, s0, 1
	addi s1, s1, 5
	j greater_than_equal

not_equal:
	bne s1, s2, end
	addi s0, s0, 1
	addi s1, s1, 5
	j not_equal

end:
sw s0 0(s0)


# Valor final no s0/x8 = 0x06