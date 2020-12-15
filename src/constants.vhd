use std.textio.all;

package constants is
	constant data_width : integer := 32;
	constant dmemory_size : integer := 32;
	constant imemory_width : integer := 10;
	constant dmemory_width : integer := 10;
	constant memory_file : string := "code.txt";
	type op_t is (lui, jal, jalr, beq, bne, blt, bge, lb, lw, sb, sw, 
		addi, slti, xori, ori, andi, add, sub, 
		sll_op, slt, xor_op, srl_op, sra_op, or_op, and_op, system, nop, othrs
	);
end package constants;

package body constants is
end package body constants;
