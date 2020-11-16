library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
	generic(
		data_width : integer := 32
	);
	port(
		data1 : in std_logic(data_width-1 downto 0);
		data2 : in std_logic(data_width-1 downto 0);
		sel : in std_logic;
		output : out std_logic(data_width-1 downto 0)
	);
end entity mux;

architecture RTL of mux is
	
begin
	output <=  data1 when sel = '0' else data2;
end architecture RTL;
