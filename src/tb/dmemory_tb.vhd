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
	signal write_byte : std_logic;
	signal read_byte : std_logic;
	
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
			dmemory_width => dmemory_width
		)
		port map(
			clk => clk,
			mem_write => mem_write,
			write_byte => write_byte,
			mem_read => mem_read,
			read_byte => read_byte,
			addr => addr(dmemory_width-1 downto 0),
			write_data => write_data,
			read_data => read_data
		);
		
	stimulus : process
	begin
		mem_write <= '0';
		mem_read <= '0';
		write_byte <= '0';
		read_byte  <= '0';
		addr <= std_logic_vector(to_unsigned(0, data_width));
		write_data <= std_logic_vector(to_signed(0, data_width));
		wait for 5 ns;
		addr <= std_logic_vector(to_unsigned(4, data_width));
		write_data <= std_logic_vector(to_signed(10, data_width));
		mem_write <= '1';
		wait for 10 ns;
		mem_write <='0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(8, data_width));
		write_data <= std_logic_vector(to_signed(11, data_width));
		mem_write <= '1';
		wait for 10 ns;
		mem_write <='0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(4, data_width));
		mem_read <= '1';
		wait for 10 ns;
		mem_read <='0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(8, data_width));
		mem_read <= '1';
		wait for 10 ns;
		mem_read <='0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(12, data_width));
		write_data <= std_logic_vector(to_signed(-1, data_width));
		mem_write <= '1';
		wait for 10 ns;
		mem_write <='0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(13, data_width));
		write_data <= std_logic_vector(to_signed(0, data_width));
		mem_write <= '1';
		write_byte <= '1';
		wait for 10 ns;
		mem_write <='0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(14, data_width));
		write_data <= std_logic_vector(to_signed(5, data_width));
		mem_write <= '1';
		write_byte <= '1';
		wait for 10 ns;
		mem_write <='0';
		write_byte <= '0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(12, data_width));
		mem_read <= '1';
		wait for 10 ns;
		mem_read <='0';
		wait for 10 ns;
		addr <= std_logic_vector(to_unsigned(14, data_width));
		mem_read <= '1';
		read_byte <= '1';
		wait for 10 ns;
		mem_read <='0';
		read_byte <= '0';
		wait for 15 ns;
	end process;
		
end architecture RTL;
