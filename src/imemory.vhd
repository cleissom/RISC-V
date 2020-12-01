library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity imemory is
	generic(memory_file : string := "code.txt";
		data_width: integer := 8;			-- data width (fixed)
		imemory_width: integer := 16);			-- address width
	port(
		clk: in std_logic;
		addr : in std_logic_vector(imemory_width - 1 downto 0);		--address bus
		data_o: out std_logic_vector(31 downto 0)	--read data bus
	);
end entity imemory;

architecture behavioral of imemory is
	
type ram is array((2**imemory_width)-1 downto 0) of std_logic_vector(data_width - 1 downto 0);
signal ram1 : ram := (others => (others => '0'));

begin
    
	process
		variable data : std_logic_vector(data_width-1 downto 0); 
		variable index : natural := 0;
		file load_file : text open read_mode is "code.txt";
		variable hex_file_line : line;
	begin
		--Load in the ram executable image
		if index = 0 then
			while not endfile(load_file) loop
				readline(load_file, hex_file_line);
				hread(hex_file_line, data);
				ram1(index) <= data;
				index := index + 1;
				hread(hex_file_line, data);
                ram1(index) <= data;
                index := index + 1;
                hread(hex_file_line, data);
                ram1(index) <= data;
                index := index + 1;
                hread(hex_file_line, data);
                ram1(index) <= data;
                index := index + 1;
			end loop;
		end if;
		wait;
	end process;
	
	data_o <= ram1(To_integer(Unsigned(addr))+3) & ram1(To_integer(Unsigned(addr))+2) & ram1(To_integer(Unsigned(addr))+1) & ram1(To_integer(Unsigned(addr)));


end architecture behavioral;


architecture rtl of imemory is
	
-- Build a 2-D array type for the RoM
	subtype word_t is std_logic_vector(31 downto 0);
	type memory_t is array((2**imemory_width)-1 downto 0) of word_t;
		
	function init_rom
		return memory_t is
		variable tmp : memory_t := (others => (others => '0'));
		begin
			for addr_pos in 0 to (2**imemory_width)-1 loop
				-- Initialize each address with the address itself
				tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, 32));
			end loop;
		return tmp;
	end init_rom;
	
	-- Declare the ROM signal and specify a default value.	Quartus II
	-- will create a memory initialization file (.mif) based on the 
	-- default value.
	signal rom : memory_t := init_rom;
					
signal word_addr : std_logic_vector(imemory_width - 1 downto 2);

begin

	word_addr <= addr(imemory_width - 1 downto 2);
	
	process(clk)
	begin
		if(falling_edge(clk)) then
			data_o <= rom(to_integer(unsigned(word_addr)));
		end if;
	end process;


end architecture rtl;
