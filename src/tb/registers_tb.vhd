library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity registers_tb is
end entity registers_tb;

architecture RTL of registers_tb is
	signal clk : std_logic;
	signal read_reg1 : std_logic_vector(4 downto 0);
	signal read_reg2 : std_logic_vector(4 downto 0);
	signal write_reg : std_logic_vector(4 downto 0);
	signal reg_write : std_logic;
	signal read_data1 : std_logic_vector(data_width-1 downto 0);
	signal read_data2 : std_logic_vector(data_width-1 downto 0);
	signal write_data : std_logic_vector(data_width-1 downto 0);

begin

	dut: entity work.registers
		generic map(
			data_width => data_width
		)
		port map(
			clk        => clk,
			read_reg1  => read_reg1,
			read_reg2  => read_reg2,
			write_reg  => write_reg,
			wreg  => reg_write,
			write_data => write_data,
			read_data1 => read_data1,
			read_data2 => read_data2
		);
		
	clock_driver : process
		constant period : time := 10 ns;
	begin
		clk <= '0';
		wait for period / 2;
		clk <= '1';
		wait for period / 2;
	end process clock_driver;
		
	stilumus: process
	begin
		read_reg1  <= std_logic_vector(to_unsigned(6, 5));
		read_reg2  <= std_logic_vector(to_unsigned(7, 5));
		write_reg  <= std_logic_vector(to_unsigned(8, 5));
		write_data <= std_logic_vector(to_unsigned(20, data_width));
		reg_write  <= '0';
		wait for 5 ns;
		reg_write  <= '1';
		wait for 10 ns;
		reg_write  <= '0';
		wait for 10 ns;
		read_reg1  <= std_logic_vector(to_unsigned(8, 5));
		read_reg2  <= std_logic_vector(to_unsigned(9, 5));
		write_reg  <= std_logic_vector(to_unsigned(9, 5));
		write_data <= std_logic_vector(to_unsigned(30, data_width));
		reg_write  <= '1';
		wait for 10 ns;
		reg_write  <= '0';
		wait for 5 ns;
	end process;
		
end architecture RTL;
