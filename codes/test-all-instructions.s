
##### Register-immediate operations test #####
addi s0, x0, 0x4AC
andi s1, s0, 0x1DC	# result 0x8C
ori  s2, s1, 0x10D	# result 0x18D
xori s3, s2, -0x7DD	# result 0xFFFFF9AE


##### Register-register operations test #####
li s4, 4 
li s5, 5

add t0, s0, s2	# result 0x639
sub t0, t0, s1	# result 0x5AD
and t0, t0, s3	# result 0x1AC
xor t0, t0, s0	# result 0x500
or  t0, t0, s3	# result 0xFFFFFDAE
sll t0, t0, s4	# result 0xFFFFDAE0
srl t0, t0, s5	# result 0x07FFFED7
slt t0, s3, t0	# result 0x1


##### Jumps and Branches operations test #####
jal test_branches
mv s0, a0	# place return value on s0 (must be 0x6)


##### Load and Store operations test #####
lui s0, 0xCE66B
addi s0, s0, 0x44E	# result s0/x8 = 0xCE66B44E
addi s1, x0, 0x75

sw s0, 0(x0)	
sb s1, 1(x0)
lw t0, 0(x0)	# result t0/x5 = 0xCE66754E
lb t1, 2(x0)	# result t1/x6 = 0x66

j end



test_branches:

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
		bne s1, s2, end_test_branches
		addi s0, s0, 1
		addi s1, s1, 5
		j not_equal

	end_test_branches:
	mv a0, s0 # Valor final no s0/x8 = 0x06
	jalr x0, x1, 0	# return

end:
