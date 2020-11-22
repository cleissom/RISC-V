li x1, 0
li x2, 0
li x3, 4

equal:
	beq x2, x3, less_than
	addi x1, x1, 1
	addi x2, x2, 1
	j equal

less_than:
	blt x2, x3, greater_than_equal
	addi x1, x1, 1
	addi x2, x2, -2
	j less_than


greater_than_equal:
	bge x2, x3, not_equal
	addi x1, x1, 1
	addi x2, x2, 5
	j greater_than_equal

not_equal:
	bne x2, x3, end
	addi x1, x1, 1
	addi x2, x2, 5
	j not_equal

end:
sw x1 0(x1)


# Valor final no x1 = 0x06