library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dmemory is
	generic(
		dmemory_width : integer := 10
	);
	port(
		clk : in std_logic;
		mem_write : in std_logic;
		write_byte: in std_logic;
		mem_read  : in std_logic;
		read_byte: in std_logic;
		addr : in std_logic_vector(dmemory_width-1 downto 0);
		write_data : in std_logic_vector(31 downto 0);
		read_data : out std_logic_vector(31 downto 0)
	);
end entity dmemory;

architecture RTL of dmemory is
	type memory_array is array((2**dmemory_width)-1 downto 0) of std_logic_vector(7 downto 0);
	signal ram : memory_array := (others => (others => '0'));
	
	signal bram_addr : std_logic_vector(dmemory_width - 1 downto 2);
	
	signal byte_data : std_logic_vector(7 downto 0);
	signal word_data : std_logic_vector(31 downto 0);
	
	signal data_o_block0 : std_logic_vector(7 downto 0);
	signal data_o_block1 : std_logic_vector(7 downto 0);
	signal data_o_block2 : std_logic_vector(7 downto 0);
	signal data_o_block3 : std_logic_vector(7 downto 0);
	signal data_i_block0 : std_logic_vector(7 downto 0);
	signal data_i_block1 : std_logic_vector(7 downto 0);
	signal data_i_block2 : std_logic_vector(7 downto 0);
	signal data_i_block3 : std_logic_vector(7 downto 0);
	
	signal byte_addr : std_logic_vector(1 downto 0);
	
	signal cs_n_0 : std_logic;
	signal cs_n_1 : std_logic;
	signal cs_n_2 : std_logic;
	signal cs_n_3 : std_logic;
	
	signal we_n : std_logic;
	
	signal read_data_internal : std_logic_vector(31 downto 0);
	
begin
	
	
	
	byte_addr <= addr(1 downto 0);
	
	byte_data <= data_o_block1 when byte_addr = "01" else
				data_o_block2 when byte_addr = "10" else
				data_o_block3 when byte_addr = "11" else
				data_o_block0;
				
	word_data <= data_o_block3 & data_o_block2 & data_o_block1 & data_o_block0;
	
	read_data_internal <=  word_data when read_byte = '0' else
				x"000000" & byte_data;
				
	read_data <=  read_data_internal when mem_read = '1';
	
	data_i_block0 <= write_data(7 downto 0);
	data_i_block1 <= write_data(7 downto 0) when write_byte = '1' else
					write_data(15 downto 8);
	data_i_block2 <= write_data(7 downto 0) when write_byte = '1' else
					write_data(23 downto 16);
	data_i_block3 <= write_data(7 downto 0) when write_byte = '1' else
					write_data(31 downto 24);
	
	cs_n_0 <= '0' when (write_byte = '1' and byte_addr = "00") or write_byte = '0' else
			'1';
	cs_n_1 <= '0' when (write_byte = '1' and byte_addr = "01") or write_byte = '0' else
			'1';
	cs_n_2 <= '0' when (write_byte = '1' and byte_addr = "10") or write_byte = '0' else
			'1';
	cs_n_3 <= '0' when (write_byte = '1' and byte_addr = "11") or write_byte = '0' else
			'1';
	
	bram_addr <= addr(dmemory_width - 1 downto 2);
	we_n <= not mem_write;
	
	block0: entity work.bram
		generic map(
			data_width    => 8,
			address_width => dmemory_width,
			bank          => 0
		)
		port map(
			clk    => clk,
			addr   => bram_addr,
			cs_n   => cs_n_0,
			we_n   => we_n,
			data_i => data_i_block0,
			data_o => data_o_block0
		);
		
	block1: entity work.bram
		generic map(
			data_width    => 8,
			address_width => dmemory_width,
			bank          => 1
		)
		port map(
			clk    => clk,
			addr   => bram_addr,
			cs_n   => cs_n_1,
			we_n   => we_n,
			data_i => data_i_block1,
			data_o => data_o_block1
		);
		
	block2: entity work.bram
		generic map(
			data_width    => 8,
			address_width => dmemory_width,
			bank          => 2
		)
		port map(
			clk    => clk,
			addr   => bram_addr,
			cs_n   => cs_n_2,
			we_n   => we_n,
			data_i => data_i_block2,
			data_o => data_o_block2
		);
		
	block3: entity work.bram
		generic map(
			data_width    => 8,
			address_width => dmemory_width,
			bank          => 3
		)
		port map(
			clk    => clk,
			addr   => bram_addr,
			cs_n   => cs_n_3,
			we_n   => we_n,
			data_i => data_i_block3,
			data_o => data_o_block3
		);
	
	
end architecture RTL;
