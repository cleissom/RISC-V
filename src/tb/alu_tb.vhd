library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture RTL of alu_tb is	
	signal op1 : std_logic_vector(31 downto 0);
	signal op2 : std_logic_vector(31 downto 0);
	signal alu_op : std_logic_vector(3 downto 0);
	signal result : std_logic_vector(31 downto 0);
	signal zero : std_logic;
	signal less_than : std_logic;
	

	
begin
	
	dut : entity work.alu
		port map(
			op1       => op1,
			op2       => op2,
			alu_op    => alu_op,
			result    => result,
			zero      => zero,
			less_than => less_than
		);		
	stilumus: process
	begin
		op1 <= std_logic_vector(to_signed(5,32));
		op2 <= std_logic_vector(to_signed(-7,32));
		alu_op    <= "0000";
		wait for 5 ns;
		alu_op    <= "0001";
		wait for 5 ns;
		alu_op    <= "0010";
		wait for 5 ns;
		alu_op    <= "0100";
		wait for 5 ns;
		alu_op    <= "0101";
		wait for 5 ns;
		alu_op    <= "0110";
		wait for 5 ns;
		alu_op    <= "0111";
		wait for 5 ns;
		alu_op    <= "1001";
		op2 <= std_logic_vector(to_signed(2,32));
		wait for 5 ns;
		alu_op    <= "1010";
		wait for 5 ns;
		op2 <= std_logic_vector(to_signed(10,32));
		wait for 10 ns;
	end process;
		
end architecture RTL;
