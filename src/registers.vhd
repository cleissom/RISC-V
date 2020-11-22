library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is
	generic(
		data_width : integer := 32
	);
	port(
		clk : in std_logic;
		read_reg1 : in std_logic_vector(4 downto 0);
		read_reg2 : in std_logic_vector(4 downto 0);
		write_reg : in std_logic_vector(4 downto 0);
		wreg : in std_logic;
		write_data : in  std_logic_vector(data_width-1 downto 0);
		read_data1 : out std_logic_vector(data_width-1 downto 0);
		read_data2 : out std_logic_vector(data_width-1 downto 0)
	);
end entity registers;

architecture RTL of registers is
	type memory_array is array(0 to 31) of std_logic_vector(data_width-1 downto 0);
	signal registers : memory_array := (others => (others => '0'));
begin
	
	read_data1 <= write_data when (wreg = '1' and read_reg1 = write_reg) else 
				registers(to_integer(unsigned(read_reg1))) when read_reg1 /= "00000" else
				(others => '0');
	read_data2 <= write_data when (wreg = '1' and read_reg2 = write_reg) else 
				registers(to_integer(unsigned(read_reg2))) when read_reg2 /= "00000" else
				(others => '0');

	process(clk)
	begin
		if rising_edge(clk) then
			if wreg = '1' and write_reg /= "00000" then
				registers(to_integer(unsigned(write_reg))) <= write_data;
			end if;
		end if;
	end process;
	
end architecture RTL;
