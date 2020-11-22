library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_tb is
end entity datapath_tb;

architecture RTL of datapath_tb is
	signal clk : std_logic;
	signal reset : std_logic;
	
begin
	
	clock_driver : process
		constant period : time := 10 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
	
	dut: entity work.datapath
		port map(
			clock => clk,
			reset => reset
		);
		
	stimulus : process
	begin

		reset <= '1';
		wait for 10 ns;
		reset <= '0';
		wait;
		
	end process;
	
end architecture RTL;
