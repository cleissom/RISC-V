library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity add_tb is
end entity add_tb;

architecture RTL of add_tb is
	signal data1 : std_logic_vector(data_width-1 downto 0);
	signal data2 : std_logic_vector(data_width-1 downto 0);
	signal output : std_logic_vector(data_width-1 downto 0);
	
begin
	dut: entity work.add
		generic map(
			data_width => data_width
		)
		port map(
			data1  => data1,
			data2  => data2,
			output => output
		);
	
	stimulus: process
	begin
		data1 <= std_logic_vector(to_signed(3,data_width));
		data2 <= std_logic_vector(to_signed(-7,data_width));
		wait for 10 ns;
		data2 <= std_logic_vector(to_signed(5,data_width));
		wait for 10 ns;
	end process;
end architecture RTL;
