library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	generic(
		data_width: integer := 32
	);
	port(
		data1	: in  std_logic_vector(data_width-1 downto 0);
		data2	: in  std_logic_vector(data_width-1 downto 0);
		op		: in  std_logic_vector(3 downto 0);
		result	: out std_logic_vector(data_width-1 downto 0);
		zero	: out std_logic
	);
end entity alu;
	
architecture RTL of alu is
	signal r : std_logic_vector(data_width-1 downto 0);
begin
	
	zero <= '0' when r = (data_width-1 downto 0 => '0') else '1';
	
	with op select
			r <= 	data1 and data2 when "0000",
						data1 or data2 when "0001",
						std_logic_vector(signed(data1) + signed(data2)) when "0010",
						std_logic_vector(signed(data1) - signed(data2)) when "0110",
						(others => '0') when others;
	result <= r;
	
end architecture RTL;
