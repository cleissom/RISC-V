# This example shows an implementation of the mathematical
# factorial function (! function) to find the factorial value of !7 = 5040.

.text
main:
		li	sp, 1000
        li  a0, 7   # Load argument from static data
        jal ra, fact       # Jump-and-link to the 'fact' label

        # Print the result to console
        mv  a1, a0
        sw 	a1, 0(x0)
        # Exit program
        j end

fact:
        addi sp, sp, -16
        sw   ra, 8(sp)
        sw   a0, 0(sp)
        addi t0, a0, -1
        bge  t0, zero, nfact

        addi a0, zero, 1
        addi sp, sp, 16
        jr x1

nfact:
        addi a0, a0, -1
        jal  ra, fact
        addi t1, a0, 0
        lw   a0, 0(sp)
        lw   ra, 8(sp)
        addi sp, sp, 16
        mul a0, a0, t1
        ret

end: