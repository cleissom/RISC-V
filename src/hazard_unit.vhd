library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_unit is
	port(
		rs1 : in std_logic_vector(4 downto 0);
		rs2 : in std_logic_vector(4 downto 0);
		rd_EX : in std_logic_vector(4 downto 0);
		mem_read_EX : in std_logic;
		stall : out std_logic
	);
end entity hazard_unit;

architecture RTL of hazard_unit is
	
begin
	stall <= '1' when mem_read_EX = '1' and (rd_EX = rs1 or rd_EX = rs2) else 
			'0';
end architecture RTL;
