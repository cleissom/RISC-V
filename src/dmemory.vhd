library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmemory is
	generic(
		data_width : integer := 32
	);
	port(
		clk : in std_logic;
		mem_write : in std_logic;
		mem_read  : in std_logic;
		addr : in std_logic_vector(data_width-1 downto 0);
		write_data : in std_logic_vector(data_width-1 downto 0);
		read_data : out std_logic_vector(data_width-1 downto 0)
	);
end entity dmemory;

architecture RTL of dmemory is
	type memory_array is array(0 to 31) of std_logic_vector(data_width-1 downto 0);
	signal ram : memory_array := (others => (others => '0'));
	
begin

	process (clk) is
	begin
		if rising_edge(clk) then
			if mem_write = '1' then
				ram(to_integer(unsigned(addr))) <= write_data;
			elsif mem_read = '1' then
				read_data <= ram(to_integer(unsigned(addr)));
			end if;
		end if;
	end process;
	

	
	
	
end architecture RTL;
