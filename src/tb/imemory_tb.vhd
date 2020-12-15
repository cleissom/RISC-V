library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity imemory_tb is
end entity imemory_tb;

architecture RTL of imemory_tb is
	signal clk : std_logic;
	signal addr : std_logic_vector(data_width-1 downto 0);
	signal read_data : std_logic_vector(data_width-1 downto 0);
	
begin
	
	clock_driver : process
		constant period : time := 10 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
	
	dut: entity work.imemory
		generic map(
			imemory_width => imemory_width
		)
		port map(
			clk => clk,
			addr   => addr(imemory_width-1 downto 0),
			data_o => read_data
		);
		
	stimulus : process
	begin

		addr <= std_logic_vector(to_unsigned(0, data_width));
		wait for 5 ns;
		addr <= std_logic_vector(to_unsigned(4, data_width));
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(8, data_width));
        wait for 10 ns;
        addr <= std_logic_vector(to_unsigned(12, data_width));
        wait for 10 ns;
        addr <= std_logic_vector(to_unsigned(16, data_width));
        wait for 10 ns;
		
	end process;

end architecture RTL;
