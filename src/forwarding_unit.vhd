library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is
	port(
		rs1_EX : in std_logic_vector(4 downto 0);
		rs2_EX : in std_logic_vector(4 downto 0);
		
		rd_MEM : in std_logic_vector(4 downto 0);
		reg_write_MEM : in std_logic;
		
		rd_WB : in std_logic_vector(4 downto 0);
		reg_write_WB : in std_logic;
		
		forward_a : out std_logic_vector(1 downto 0);
		forward_b : out std_logic_vector(1 downto 0)
	);
end entity forwarding_unit;

architecture RTL of forwarding_unit is
	
begin
	forward_a <= "01" when (reg_write_MEM = '1' and rd_MEM /= "00000") and (rd_MEM = rs1_EX) else
				 "10" when (reg_write_WB = '1' and rd_WB /= "00000") 
							and not(reg_write_MEM = '1' and rd_MEM /= "00000" and rd_MEM = rs1_EX) 
							and (rd_WB = rs1_EX) else
				"00";
				
	forward_b <= "01" when (reg_write_MEM = '1' and rd_MEM /= "00000") and (rd_MEM = rs2_EX) else
				 "10" when (reg_write_WB = '1' and rd_WB /= "00000") 
							and not(reg_write_MEM = '1' and rd_MEM /= "00000" and rd_MEM = rs2_EX) 
							and (rd_WB = rs2_EX) else
				"00";
end architecture RTL;
