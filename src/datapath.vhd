library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity datapath is
	port(
		clock : in std_logic;
		reset : in std_logic
	);
end entity datapath;

architecture RTL of datapath is
	-- control signals
	signal reg_write_ctl, alu_src1_ctl, alu_src2_ctl, sig_read_ctl, branch_ctl: std_logic;
	signal mem_write_ctl, mem_read_ctl: std_logic_vector(1 downto 0);
	signal alu_op_ctl: std_logic_vector(3 downto 0);
	signal jump_ctl : std_logic;

	
	-- 1
	signal pc : std_logic_vector(31 downto 0);
	signal pc_last : std_logic_vector(31 downto 0);
	signal stall : std_logic := '0';
	signal mwait : std_logic := '0';
	signal stall_reg : std_logic := '0';
	signal pc_next : std_logic_vector(31 downto 0);
	signal pc_plus4 : std_logic_vector(31 downto 0);
	signal branch : std_logic_vector(31 downto 0);
	signal branch_taken : std_logic;
	signal inst_in : std_logic_vector(31 downto 0) := (others => '0');
	signal inst_in_ID : std_logic_vector(31 downto 0);
	
	-- 2
	signal inst_in_s: std_logic_vector(31 downto 0);
	signal opcode, funct7: std_logic_vector(6 downto 0);
	signal funct3: std_logic_vector(2 downto 0);
	signal rs1, rs2, rd: std_logic_vector(4 downto 0);
	signal imm_i, imm_s, imm_sb, imm_uj: std_logic_vector(31 downto 0);
	signal imm_u: std_logic_vector(31 downto 0);
	signal ext32: std_logic_vector(31 downto 12);
	
	
	
	signal reg_read_data1 : std_logic_vector(data_width-1 downto 0);
	signal reg_read_data2 : std_logic_vector(data_width-1 downto 0);
	signal reg_read_data1_EX : std_logic_vector(data_width-1 downto 0);
	signal reg_read_data2_EX : std_logic_vector(data_width-1 downto 0);
	
	-- 3
	signal alu_src1 : std_logic_vector(data_width-1 downto 0);
	signal alu_src2 : std_logic_vector(31 downto 0);
	signal alu_result : std_logic_vector(31 downto 0);
	signal zero : std_logic;
	signal less_than : std_logic;
	
	signal immediate : std_logic_vector(31 downto 0)  := (others => '0');
	signal immediate_EX : std_logic_vector(31 downto 0);
	signal pc_EX : std_logic_vector(31 downto 0);
	signal pc_ID : std_logic_vector(31 downto 0);
	
	signal alu_src1_ctl_EX : std_logic;
	signal alu_src2_ctl_EX : std_logic;
	signal alu_op_ctl_EX : std_logic_vector(3 downto 0);
	signal branch_ctl_MEM : std_logic;
	
	signal rd_EX : std_logic_vector(4 downto 0);
	signal reg_write_ctl_EX : std_logic;	
	signal branch_ctl_EX : std_logic;
	signal mem_write_ctl_EX : std_logic_vector(1 downto 0);
	signal mem_read_ctl_EX : std_logic_vector(1 downto 0);
	signal jump_ctl_EX : std_logic;
	
	signal branch_MEM : std_logic_vector(31 downto 0);
	signal zero_MEM : std_logic;
	signal alu_result_MEM : std_logic_vector(31 downto 0);
	signal rd_MEM : std_logic_vector(4 downto 0);
	signal reg_write_ctl_MEM : std_logic;
	signal reg_read_data2_MEM : std_logic_vector(31 downto 0);
	signal mem_write_ctl_MEM : std_logic_vector(1 downto 0);
    signal mem_read_ctl_MEM : std_logic_vector(1 downto 0);
	signal jump_ctl_MEM : std_logic;
	
	signal rd_WB : std_logic_vector(4 downto 0);
	signal reg_write_ctl_WB : std_logic;
	signal alu_result_WB : std_logic_vector(31 downto 0);
	signal mem_read_data_WB : std_logic_vector(31 downto 0);
	
	signal reg_write_data : std_logic_vector(31 downto 0);
	signal mem_read_data : std_logic_vector(31 downto 0) := (others => '0');
	signal mem_read_data_block : std_logic_vector(31 downto 0);
	
	signal byte_addr : std_logic_vector(1 downto 0);
	
	
begin
	
	
--
-- INSTRUCTION FETCH STAGE (IF)
--
-- 1st stage, instruction memory access, PC update
	
	-- program counter logic
	process(clock, reset, stall_reg)
	begin
		if reset = '1' then
			pc <= (others => '0');
			pc_last <= (others => '0');
		elsif rising_edge(clock) then
			if stall_reg = '0' then
				pc <= pc_next;
			else
				pc <= pc_last;
			end if;
			pc_last <= pc;
		end if;
	end process;
	
	pc_plus4 <=	Std_logic_vector(Unsigned(pc) + 4);
	
	pc_next <=	branch_MEM when branch_taken = '1' else
			pc_plus4;


	imemory: entity work.imemory
		generic map(
			memory_file  => memory_file,
			imemory_width => imemory_width
		)
		port map(
			addr   => pc(imemory_width-1 downto 0),
			data_o => inst_in
		);
	
	-- pipeline register IF/ID
	process(clock, reset)
	begin
		if reset = '1' then
			inst_in_ID <= (others => '0');
			pc_ID <= (others => '0');
		elsif rising_edge(clock) then
			inst_in_ID <= inst_in;
			pc_ID <= pc;
		end if;
	end process;
	
--
-- INSTRUCTION DECODE STAGE (ID)
--
-- 2nd stage, instruction decode, control unit operation, pipeline bubble insertion logic on load/store and branches
	
	
	-- pipeline bubble insertion on loads/stores, exceptions, branches
	inst_in_s <= x"00000000" when stall_reg = '1' or branch_taken = '1' else
		inst_in_ID;

	-- instruction decode
	opcode <= inst_in_s(6 downto 0);
	funct3 <= inst_in_s(14 downto 12);
	funct7 <= inst_in_s(31 downto 25);
	rd <= inst_in_s(11 downto 7);
	rs1 <= inst_in_s(19 downto 15);
	rs2 <= inst_in_s(24 downto 20);
	imm_i <= ext32(31 downto 12) & inst_in_s(31 downto 20);
	imm_s <= ext32(31 downto 12) & inst_in_s(31 downto 25) & inst_in_s(11 downto 7);
	imm_sb <= ext32(31 downto 13) & inst_in_s(31) & inst_in_s(7) & inst_in_s(30 downto 25) & inst_in_s(11 downto 8) & '0';
	imm_u <= inst_in_s(31 downto 12) & x"000";
	imm_uj <= ext32(31 downto 21) & inst_in_s(31) & inst_in_s(19 downto 12) & inst_in_s(20) & inst_in_s(30 downto 21) & '0';
	ext32 <= (others => '1') when inst_in_s(31) = '1' else (others => '0');
	
	-- immediate generator
	immediate <= imm_i  when opcode = "0010011" or opcode = "0000011" else -- I
				 imm_s  when opcode = "0100011" else -- S
				 imm_sb when opcode = "1100011" else -- SB
				 imm_u  when opcode = "0100111" else -- U
				 imm_uj when opcode = "1101111";     -- UJ
				
	
	
	
	
	-- control unit
	control_unit: entity work.control
	port map(	opcode => opcode,
			funct3 => funct3,
			funct7 => funct7,
			reg_write => reg_write_ctl,
			alu_src1 => alu_src1_ctl,
			alu_src2 => alu_src2_ctl,
			alu_op => alu_op_ctl,
			branch => branch_ctl,
			jump => jump_ctl,
			mem_write => mem_write_ctl,
			mem_read => mem_read_ctl,
			sig_read => sig_read_ctl
	);
	

	register_bank: entity work.registers
		generic map(
			data_width => data_width
		)
		port map(
			clk        => clock,
			read_reg1  => rs1,
			read_reg2  => rs2,
			write_reg  => rd_WB,
			wreg  => reg_write_ctl_WB,
			write_data => reg_write_data,
			read_data1 => reg_read_data1,
			read_data2 => reg_read_data2
		);
	
		
	-- pipeline register ID/EX
	process(clock, reset)
	begin
		if reset = '1' then
			reg_read_data1_EX <= (others => '0');
			reg_read_data2_EX <= (others => '0');
			rd_EX <= (others => '0');
			immediate_EX <= (others => '0');
			pc_EX <= (others => '0');
			alu_src1_ctl_EX <= '0';
			alu_src2_ctl_EX <= '0';
			alu_op_ctl_EX <= (others => '0');
			branch_ctl_EX <= '0';
			reg_write_ctl_EX <= '0';
			mem_read_ctl_EX <= (others => '0');
			mem_write_ctl_EX <= (others => '0');
			jump_ctl_EX <= '0';
		elsif rising_edge(clock) then
			reg_read_data1_EX <= reg_read_data1;
			reg_read_data2_EX <= reg_read_data2;
			rd_EX <= rd;
			immediate_EX <= immediate;
			pc_EX <= pc_ID;
			alu_src1_ctl_EX <= alu_src1_ctl;
			alu_src2_ctl_EX <= alu_src2_ctl;
			alu_op_ctl_EX <= alu_op_ctl;
			branch_ctl_EX <= branch_ctl;
			reg_write_ctl_EX <= reg_write_ctl;
			mem_read_ctl_EX <= mem_read_ctl;
			mem_write_ctl_EX <= mem_write_ctl;
			jump_ctl_EX <= jump_ctl;
		end if;
	end process;

--
-- EXECUTION STAGE (EX)
--
-- 3rd stage, instruction decode, control unit operation, pipeline bubble insertion logic on load/store and branches
	
    alu_src1 <= reg_read_data1_EX when alu_src1_ctl_EX = '0' else
                pc_EX;
    alu_src2 <= reg_read_data2_EX when alu_src2_ctl_EX = '0' else
                immediate_EX;
	
	
	alu: entity work.alu
		port map(
			op1       => alu_src1,
			op2       => alu_src2,
			alu_op    => alu_op_ctl_EX,
			result    => alu_result,
			zero      => zero,
			less_than => less_than
		);
	
	-- branch
	branch <= Std_logic_vector(Unsigned(pc_EX) + Unsigned(immediate_EX));
	
	
	
	-- pipeline register EX/MEM
	process(clock, reset)
	begin
		if reset = '1' then
		    alu_result_MEM <= (others => '0');
			branch_MEM <= (others => '0');
			zero_MEM <= '0';
			branch_ctl_MEM <= '0';
			rd_MEM <= (others => '0');
			reg_read_data2_MEM <= (others => '0');
			reg_write_ctl_MEM <= '0';
			mem_read_ctl_MEM <= (others => '0');
            mem_write_ctl_MEM <= (others => '0');
            jump_ctl_MEM <= '0';
		elsif rising_edge(clock) then
		    alu_result_MEM <= alu_result;
			branch_MEM <= branch;
			zero_MEM <= zero;
			branch_ctl_MEM <= branch_ctl_EX;
			rd_MEM <= rd_EX;
			reg_read_data2_MEM <= reg_read_data2_EX;
			reg_write_ctl_MEM <= reg_write_ctl_EX;
			mem_read_ctl_MEM <= mem_read_ctl_EX;
            mem_write_ctl_MEM <= mem_write_ctl_EX;
            jump_ctl_MEM <= jump_ctl_EX;
		end if;
	end process;
	
	
--
-- MEMORY ACESS STAGE (MEM)
--
-- 4th stage, instruction decode, control unit operation, pipeline bubble insertion logic on load/store and branches
	
	branch_taken <= '1' when (zero_MEM = '1' and branch_ctl_MEM = '1') or jump_ctl_MEM = '1'
					else '0';
	
	
	dmemory: entity work.dmemory
	    generic map(
	        dmemory_width => dmemory_width
	    )
	    port map(
	        clk        => clock,
	        mem_write  => mem_write_ctl_MEM(0),
	        write_byte => mem_write_ctl_MEM(1),
	        mem_read   => mem_read_ctl_MEM(0),
	        addr       => alu_result_MEM(dmemory_width-1 downto 0),
	        write_data => reg_read_data2_MEM,
	        read_data  => mem_read_data_block
	    );

	    
	    
    byte_addr <= alu_result_MEM(1 downto 0);
    mem_read_data <= (x"000000" & mem_read_data_block(7 downto 0)) when mem_read_ctl_MEM(1) = '1' and byte_addr = "00" else
    				(x"000000" & mem_read_data_block(15 downto 8)) when mem_read_ctl_MEM(1) = '1' and byte_addr = "01" else
    				(x"000000" & mem_read_data_block(23 downto 16)) when mem_read_ctl_MEM(1) = '1' and byte_addr = "10" else
    				(x"000000" & mem_read_data_block(31 downto 24)) when mem_read_ctl_MEM(1) = '1' and byte_addr = "11" else
    				mem_read_data_block;
	
	
	-- pipeline register MEM/WB
    process(clock, reset)
    begin
        if reset = '1' then
            mem_read_data_WB <= (others => '0');
            alu_result_WB <= (others => '0');
            rd_WB <= (others => '0');
            reg_write_ctl_WB <= '0';
        elsif rising_edge(clock) then
            mem_read_data_WB <= mem_read_data;
            alu_result_WB <= alu_result_MEM;
            rd_WB <= rd_MEM;
            reg_write_ctl_WB <= reg_write_ctl_MEM;
        end if;
    end process;
--
-- WRITE BACK STAGE (WB)
--
-- 5th stage, instruction decode, control unit operation, pipeline bubble insertion logic on load/store and branches
	
	reg_write_data <=  mem_read_data_WB when  reg_write_ctl_WB = '0' else
	                   alu_result_WB;
	
	
end architecture RTL;
