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
	addr : in std_logic_vector(imemory_width - 1 downto 0);		--address bus
	data_o: out std_logic_vector(31 downto 0)	--read data bus
	);
end entity imemory;

architecture RTL of imemory is
	
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


end architecture RTL;
