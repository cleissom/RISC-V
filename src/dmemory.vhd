library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmemory is
	generic(
		dmemory_width : integer := 10
	);
	port(
		clk : in std_logic;
		mem_write : in std_logic;
		write_byte: in std_logic;
		mem_read  : in std_logic;
		read_byte: in std_logic;
		addr : in std_logic_vector(dmemory_width-1 downto 0);
		write_data : in std_logic_vector(31 downto 0);
		read_data : out std_logic_vector(31 downto 0)
	);
end entity dmemory;

architecture RTL of dmemory is
	type memory_array is array((2**dmemory_width)-1 downto 0) of std_logic_vector(7 downto 0);
	signal ram : memory_array := (others => (others => '0'));
	
begin

	
	process (clk)
		variable block_addr : std_logic_vector(dmemory_width-1 downto 0);
		variable byte_addr : std_logic_vector(1 downto 0);
		begin
		if rising_edge(clk) then
			block_addr := addr(dmemory_width-1 downto 2) & "00";
			byte_addr := addr(1 downto 0);
			if mem_write = '1' then
				if write_byte = '1' then
					ram(to_integer(unsigned(addr))) <= write_data(7 downto 0);
				else				
					ram(to_integer(unsigned(block_addr))) <= write_data(7 downto 0);
					ram(to_integer(unsigned(block_addr))+1) <= write_data(15 downto 8);
					ram(to_integer(unsigned(block_addr))+2) <= write_data(23 downto 16);
					ram(to_integer(unsigned(block_addr))+3) <= write_data(31 downto 24);
				end if;
			elsif mem_read = '1' then
				if read_byte = '1' then
					read_data <= x"000000" & ram(to_integer(unsigned(block_addr)) + to_integer(unsigned(byte_addr)));
				else
					read_data <= ram(to_integer(unsigned(block_addr))+3) & ram(to_integer(unsigned(block_addr))+2) & ram(to_integer(unsigned(block_addr))+1) & ram(to_integer(unsigned(block_addr)));
				end if;
			end if;
		end if;
	end process;
	

	
	
	
end architecture RTL;
