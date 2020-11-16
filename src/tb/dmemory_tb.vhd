library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity dmemory_tb is
end entity dmemory_tb;

architecture RTL of dmemory_tb is
	signal clk : std_logic;
	signal mem_write : std_logic;
	signal mem_read : std_logic;
	signal addr : std_logic_vector(data_width-1 downto 0);
	signal write_data : std_logic_vector(data_width-1 downto 0);
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
	
	
	dut : entity work.dmemory
		generic map(
			data_width => data_width
		)
		port map(
			clk        => clk,
			mem_write  => mem_write,
			mem_read   => mem_read,
			addr       => addr,
			write_data => write_data,
			read_data  => read_data
		);
		
	stimulus : process
	begin
		mem_write <= '0';
		mem_read <= '0';
		addr <= std_logic_vector(to_unsigned(2, data_width));
		write_data <= std_logic_vector(to_signed(25, data_width));
		wait for 5 ns;
		mem_write <= '1';
		wait for 10 ns;
		mem_write <='0';
		addr <= std_logic_vector(to_unsigned(3, data_width));
		write_data <= std_logic_vector(to_signed(30, data_width));
		wait for 10 ns;
		mem_write <= '1';
		wait for 10 ns;
		mem_write <='0';
		addr <= std_logic_vector(to_unsigned(2, data_width));
		wait for 10 ns;
		mem_read <= '1';
		wait for 10 ns;
		mem_read <='0';
		addr <= std_logic_vector(to_unsigned(3, data_width));
		wait for 10 ns;
		mem_read <= '1';
		wait for 10 ns;
		mem_read <='0';
		wait for 5 ns;
	end process;
		
end architecture RTL;
