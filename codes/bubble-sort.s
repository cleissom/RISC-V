# Carregamento dos dados na memória
li t1, 0xA1577D09
sw t1, 0(x0)
li t1, 0x65E16464
sw t1, 4(x0)
li t1, 0xCB243A68
sw t1, 8(x0)
li t1, 0xED8DE247
sw t1, 12(x0)
li t1, 0xB6013CD1
sw t1, 16(x0)
li t1, 0x027C43A2
sw t1, 20(x0)
li t1, 0xB46DE9A8
sw t1, 24(x0)
li t1, 0xFA3A3C2A
sw t1, 28(x0)
li t1, 0x75F418D0
sw t1, 32(x0)
li t1, 0x23FC2ED8
sw t1, 36(x0)

# Carregamento de constantes
li sp, 100		# Stack pointer
li a0, 10		# Array size
li a1, 0		# Array address 
jal bubble_sort
j end

bubble_sort:
	mv s0, a0
	mv s1, a1
	mv s2, x0

	# s0 -> array size (N)
	# s1 -> array address
	# s2 -> k (outer loop iterator)
	# s3 -> i (inner loop iterator)

	outter_loop:

	mv s3, x0	# i=0
	inner_loop:
	
	addi t0, x0, 2
	sll t1, s3, t0	# t1 = addr <- i*4
	lw t2, 0(t1)	# A[addr]
	lw t3, 4(t1)	# A[addr+4]

	ble t2, t3, no_swap # go to no_swap if (A[i] <= A[i+1])
	
	lw t4, 0(t1)
	lw t5, 4(t1)
	sw t4, 4(t1)
	sw t5, 0(t1)

	no_swap:


	addi t0, s0, -1 # (N-1)
	addi s3, s3, 1 # i++
	blt s3, t0 inner_loop # go to inner_loop if (i < N-1)

	addi s2, s2, 1
	blt s2, s0 outter_loop # go to outter_loop if (k < N)


end: