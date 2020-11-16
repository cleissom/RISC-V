library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity alu_tb is
end entity alu_tb;

architecture RTL of alu_tb is	
	
	signal op : std_logic_vector(3 downto 0);
	signal zero : std_logic;
	signal data1 : std_logic_vector(data_width-1 downto 0);
	signal data2 : std_logic_vector(data_width-1 downto 0);
	signal result : std_logic_vector(data_width-1 downto 0);
	
begin
	
	dut : entity work.alu
		generic map(
			data_width => data_width
		)
		port map(
			data1 => data1,
			data2 => data2,
			op => op,
			result => result,
			zero => zero
		);	
		
	stilumus: process
	begin
		data1 <= std_logic_vector(to_signed(5,data_width));
		data2 <= std_logic_vector(to_signed(-7,data_width));
		op    <= "0000";
		wait for 10 ns;
		op    <= "0001";
		wait for 10 ns;
		op    <= "0010";
		wait for 5 ns;
		op    <= "0011";
		wait for 5 ns;
		op    <= "0110";
		wait for 10 ns;
	end process;
		
end architecture RTL;
