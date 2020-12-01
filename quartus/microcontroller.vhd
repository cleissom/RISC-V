library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity microcontroller is
	port(
		----------- CLK ------------
		CLOCK_50 : in std_logic;
		
		----------- KEY ------------
		KEY0: in std_logic;

		----------- LED ------------
		LEDR0: out std_logic
	);
end entity microcontroller;

architecture RTL of microcontroller is
	
begin
	datapath: entity work.datapath
		port map(
			clock => CLOCK_50,
			reset => KEY0,
			debug => LEDR0
		);

end architecture RTL;
