library ieee;
use ieee.std_logic_1164.all;

entity regn is
	generic(
		bit_width: integer
	);
	port (
		clk, clear : in std_logic;
		reg_in : in std_logic_vector(bit_width-1 downto 0);
		reg_out : out std_logic_vector(bit_width-1 downto 0)
	);
end regn;

architecture description of regn is
	signal internal_value : std_logic_vector(bit_width-1 downto 0) := (others => '0');
begin
	process (clk, clear, internal_value)
	begin
		if (clear = '1') then
			internal_value <= (others => '0');
		elsif rising_edge(clk) then
			internal_value <= reg_in;
		end if;
		reg_out <= internal_value;
	end process;
end description;