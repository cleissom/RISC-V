library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add is
	generic(
		data_width : integer := 32
	);
	port(
		data1 : in std_logic_vector(data_width-1 downto 0);
		data2 : in std_logic_vector(data_width-1 downto 0);
		output: out std_logic_vector(data_width-1 downto 0)
	);
end entity add;

architecture RTL of add is
	
begin
	output <= std_logic_vector(signed(data1) + signed(data2));
end architecture RTL;
