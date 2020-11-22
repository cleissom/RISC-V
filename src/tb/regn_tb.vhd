library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity regn_tb is
end entity regn_tb;

architecture RTL of regn_tb is
	constant bit_width_1 : integer := 1;
	constant bit_width_2 : integer := 5;
	signal reg_in_1 : std_logic_vector(bit_width_1-1 downto 0);
	signal reg_out_1 : std_logic_vector(bit_width_1-1 downto 0);
	signal reg_in_2 : std_logic_vector(bit_width_2-1 downto 0);
	signal reg_out_2 : std_logic_vector(bit_width_2-1 downto 0);
	signal clk, clear : std_logic;
	
begin
	dut1: entity work.regn
		generic map(
			bit_width => bit_width_1
		)
		port map(
			clk     => clk,
			clear   => clear,
			reg_in  => reg_in_1,
			reg_out => reg_out_1
		);
		
	dut2: entity work.regn
		generic map(
			bit_width => bit_width_2
		)
		port map(
			clk     => clk,
			clear   => clear,
			reg_in  => reg_in_2,
			reg_out => reg_out_2
		);
		
	clock_driver : process
		constant period : time := 10 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
	
	
	stimulus: process
	begin
		clear <= '1';
		wait for 5 ns;
		clear <= '0';
		reg_in_1 <= std_logic_vector(to_signed(1,bit_width_1));
		reg_in_2 <= std_logic_vector(to_signed(5,bit_width_2));
		wait for 5 ns;
		reg_in_1 <= std_logic_vector(to_signed(0,bit_width_1));
		reg_in_2 <= std_logic_vector(to_signed(15,bit_width_2));
		wait for 10 ns;
		reg_in_1 <= std_logic_vector(to_signed(0,bit_width_1));
		reg_in_2 <= std_logic_vector(to_signed(-1,bit_width_2));
		wait for 10 ns;
	end process;
end architecture RTL;
