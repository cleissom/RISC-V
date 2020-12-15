-- Control Signals
--
-- alu_op:                  alu_src1:               mem_write:		        jump:
-- 0000 -> and              0 -> r[rs1]             00 -> no mem write      00 -> no jump
-- 0001 -> or               1 -> pc                 01 -> sb                01 -> jal
-- 0010 -> xor                                      10 -> no mem write      10 -> no jump
-- 0011 -> don't care       alu_src2:               11 -> sw                11 -> jalr
-- 0100 -> add              00 -> r[rs2]
-- 0101 -> sub              01 -> imm               mem_read:               branch:
-- 0110 -> lui, jal, jalr	10 -> pc_plus4		    00 -> no mem read       000 -> no branch
-- 0111 -> slt              11 -> don't care        01 -> lb                001 -> beq
-- 1000 -> sltu                                     10 -> no mem read       010 -> bne
-- 1001 -> sll                                      11 -> lw                011 -> blt
-- 1010 -> srl                                                              100 -> bge
-- 1011 -> don't care                                                       101 -> bltu
-- 1100 -> sra                                                              110 -> bgeu
-- 1101 -> don't care       reg_write:                                      111 -> system
-- 1110 -> don't care       0 -> no write           
-- 1111 -> don't care       1 -> write register     

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity control is
	port (	opcode:			in std_logic_vector(6 downto 0);
		funct3:			in std_logic_vector(2 downto 0);
		funct7:			in std_logic_vector(6 downto 0);
		reg_write:		out std_logic;
		mem_to_reg:		out std_logic;
		alu_src1:		out std_logic;
		alu_src2:		out std_logic_vector(1 downto 0);
		alu_op:			out std_logic_vector(3 downto 0);
		branch:			out std_logic_vector(2 downto 0);
		jump:           out std_logic_vector(1 downto 0);
		mem_write:		out std_logic_vector(1 downto 0);
		mem_read:		out std_logic_vector(1 downto 0);
		op_debug:		out op_t
	);
end control;

architecture arch_control of control is
begin
	process(opcode, funct3, funct7)
	begin
		case opcode is							-- load immediate / jumps
			when "0110111" =>					-- LUI
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_src1 <= '0';
				alu_src2 <= "01";
				alu_op <= "0110";
				branch <= "000";
				jump <= "00";
				mem_write <= "00";
				mem_read <= "00";
				op_debug <= lui;
			when "1101111" =>					-- JAL
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_src1 <= '1';
				alu_src2 <= "10";
				alu_op <= "0110";
				branch <= "000";
				jump <= "01";
				mem_write <= "00";
				mem_read <= "00";
				op_debug <= jal;
			when "1100111" =>					-- JALR
				reg_write <= '1';
				mem_to_reg <= '0';
				alu_src1 <= '1';
				alu_src2 <= "10";
				alu_op <= "0110";
				branch <= "000";
				jump <= "11";
				mem_write <= "00";
				mem_read <= "00";
				op_debug <= jalr;
			when "1100011" =>					-- branches
				case funct3 is
					when "000" =>				-- BEQ
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0101";
						branch <= "001";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= beq;
					when "001" =>				-- BNE
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0101";
						branch <= "010";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= bne;
					when "100" =>				-- BLT
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0111";
						branch <= "011";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= blt;
					when "101" =>				-- BGE
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0111";
						branch <= "100";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= bge;
					when others =>
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0000";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= othrs;
				end case;
			when "0000011" => 					-- loads
				case funct3 is
					when "000" =>				-- LB
						reg_write <= '1';
						mem_to_reg <= '1';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0100";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "11";
						op_debug <= lb;
					when "010" =>				-- LW
						reg_write <= '1';
						mem_to_reg <= '1';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0100";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "01";
						op_debug <= lw;
					when others =>
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0000";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= othrs;
				end case;
			when "0100011" =>					-- stores
				case funct3 is
					when "000" =>				-- SB
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0100";
						branch <= "000";
						jump <= "00";
						mem_write <= "11";
						mem_read <= "00";
						op_debug <= sb;
					when "010" =>				-- SW
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0100";
						branch <= "000";
						jump <= "00";
						mem_write <= "01";
						mem_read <= "00";
						op_debug <= sw;
					when others =>
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0000";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= othrs;
				end case;
			when "0010011" =>					-- imm computation
				case funct3 is
					when "000" =>				-- ADDI
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0100";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= addi;
					when "010" =>				-- SLTI
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0111";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= slti;
					when "100" =>				-- XORI
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0010";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= xori;
					when "110" =>				-- ORI
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0001";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= ori;
					when "111" =>				-- ANDI
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0000";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= andi;
					when others =>
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "01";
						alu_op <= "0000";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= othrs;
				end case;
			when "0110011" =>					-- computation
				case funct3 is
					when "000" =>
						case funct7 is
							when "0000000" =>	-- ADD
								reg_write <= '1';
								mem_to_reg <= '0';
								alu_src1 <= '0';
								alu_src2 <= "00";
								alu_op <= "0100";
								branch <= "000";
								jump <= "00";
								mem_write <= "00";
								mem_read <= "00";
								op_debug <= add;
							when "0100000" =>	-- SUB
								reg_write <= '1';
								mem_to_reg <= '0';
								alu_src1 <= '0';
								alu_src2 <= "00";
								alu_op <= "0101";
								branch <= "000";
								jump <= "00";
								mem_write <= "00";
								mem_read <= "00";
								op_debug <= sub;
							when others =>
								reg_write <= '0';
								mem_to_reg <= '0';
								alu_src1 <= '0';
								alu_src2 <= "01";
								alu_op <= "0000";
								branch <= "000";
								jump <= "00";
								mem_write <= "00";
								mem_read <= "00";
								op_debug <= othrs;
						end case;
					when "001" =>				-- SLL
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "1001";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= sll_op;
					when "010" =>				-- SLT
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0111";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= slt;
					when "100" =>				-- XOR
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0010";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= xor_op;
					when "101" =>
						case funct7 is
							when "0000000" =>	-- SRL
								reg_write <= '1';
								mem_to_reg <= '0';
								alu_src1 <= '0';
								alu_src2 <= "00";
								alu_op <= "1010";
								branch <= "000";
								jump <= "00";
								mem_write <= "00";
								mem_read <= "00";
								op_debug <= srl_op;
							when "0100000" =>	-- SRA
								reg_write <= '1';
								mem_to_reg <= '0';
								alu_src1 <= '0';
								alu_src2 <= "00";
								alu_op <= "1100";
								branch <= "000";
								jump <= "00";
								mem_write <= "00";
								mem_read <= "00";
								op_debug <= sra_op;
							when others =>
								reg_write <= '0';
								mem_to_reg <= '0';
								alu_src1 <= '0';
								alu_src2 <= "01";
								alu_op <= "0000";
								branch <= "000";
								jump <= "00";
								mem_write <= "00";
								mem_read <= "00";
								op_debug <= othrs;
						end case;
					when "110" =>				-- OR
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0001";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= or_op;
					when "111" =>				-- AND
						reg_write <= '1';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0000";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= and_op;
					when others =>
						reg_write <= '0';
						mem_to_reg <= '0';
						alu_src1 <= '0';
						alu_src2 <= "00";
						alu_op <= "0000";
						branch <= "000";
						jump <= "00";
						mem_write <= "00";
						mem_read <= "00";
						op_debug <= othrs;
				end case;
			when "1110011" =>					-- SYSTEM
				reg_write <= '0';
				mem_to_reg <= '0';
				alu_src1 <= '0';
				alu_src2 <= "01";
				alu_op <= "0000";
				branch <= "111";
				jump <= "00";
				mem_write <= "00";
				mem_read <= "00";
				op_debug <= system;
				
			when "0000000" =>					-- NOP
				reg_write <= '0';
				mem_to_reg <= '0';
				alu_src1 <= '0';
				alu_src2 <= "01";
				alu_op <= "0000";
				branch <= "000";
				jump <= "00";
				mem_write <= "00";
				mem_read <= "00";
				op_debug <= nop;
			
			when others =>
				reg_write <= '0';
				mem_to_reg <= '0';
				alu_src1 <= '0';
				alu_src2 <= "01";
				alu_op <= "0000";
				branch <= "000";
				jump <= "00";
				mem_write <= "00";
				mem_read <= "00";
				op_debug <= othrs;
		end case;
	end process;
end arch_control;

