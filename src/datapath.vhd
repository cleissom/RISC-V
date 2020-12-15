library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity datapath is
	port(
		clock : in std_logic;
		reset : in std_logic;
		debug: out std_logic
	);
end entity datapath;

architecture RTL of datapath is
	-- control signals
	signal reg_write_ctl, mem_to_reg, alu_src1_ctl : std_logic;
	signal mem_write_ctl, mem_read_ctl, alu_src2_ctl, jump_ctl: std_logic_vector(1 downto 0);
	signal alu_op_ctl: std_logic_vector(3 downto 0);
	signal branch_ctl: std_logic_vector(2 downto 0);
	
	-- IF
	signal pc : std_logic_vector(31 downto 0);
	signal pc_last : std_logic_vector(31 downto 0);
	signal stall : std_logic := '0';
	signal mwait : std_logic := '0';
	signal stall_reg : std_logic := '0';
	signal pc_next : std_logic_vector(31 downto 0);
	signal pc_plus4 : std_logic_vector(31 downto 0);
	signal branch : std_logic_vector(31 downto 0);
	signal branch_taken : std_logic;
	signal jump_taken : std_logic;
	signal inst_in : std_logic_vector(31 downto 0) := (others => '0');
	
	
	-- ID
	signal opcode, funct7: std_logic_vector(6 downto 0);
	signal funct3: std_logic_vector(2 downto 0);
	signal rs1, rs2, rd: std_logic_vector(4 downto 0);
	signal imm_i, imm_s, imm_sb, imm_uj: std_logic_vector(31 downto 0);
	signal imm_u: std_logic_vector(31 downto 0);
	signal immediate : std_logic_vector(31 downto 0)  := (others => '0');
	signal ext32: std_logic_vector(31 downto 12);
	signal reg_read_data1 : std_logic_vector(data_width-1 downto 0);
	signal reg_read_data2 : std_logic_vector(data_width-1 downto 0);
	signal reg_write_data : std_logic_vector(31 downto 0);
	
	signal inst_in_ID : std_logic_vector(31 downto 0);
	signal pc_ID : std_logic_vector(31 downto 0);
	signal pc_plus4_ID : std_logic_vector(31 downto 0);
	

	-- EX
	signal alu_src1 : std_logic_vector(data_width-1 downto 0);
	signal alu_src2 : std_logic_vector(31 downto 0);
	signal alu_result : std_logic_vector(31 downto 0);
	signal zero : std_logic;
	signal less_than : std_logic;
	signal forward_mux_a : std_logic_vector(31 downto 0);
	signal forward_mux_b : std_logic_vector(31 downto 0);
	signal forward_a : std_logic_vector(1 downto 0);
	signal forward_b : std_logic_vector(1 downto 0);
	signal branch_src1 : std_logic_vector(31 downto 0);
	signal branch_src2 : std_logic_vector(31 downto 0);
	
	signal pc_EX : std_logic_vector(31 downto 0);
	signal immediate_EX : std_logic_vector(31 downto 0);
	signal reg_read_data1_EX : std_logic_vector(31 downto 0);
	signal reg_read_data2_EX : std_logic_vector(31 downto 0);
	signal alu_src1_ctl_EX : std_logic;
	signal alu_src2_ctl_EX : std_logic_vector(1 downto 0);
	signal alu_op_ctl_EX : std_logic_vector(3 downto 0);
	signal pc_plus4_EX : std_logic_vector(31 downto 0);
	signal rd_EX : std_logic_vector(4 downto 0);
	signal reg_write_ctl_EX : std_logic;
	signal mem_to_reg_EX : std_logic;
	signal branch_ctl_EX : std_logic_vector(2 downto 0);
	signal mem_write_ctl_EX : std_logic_vector(1 downto 0);
	signal mem_read_ctl_EX : std_logic_vector(1 downto 0);
	signal jump_ctl_EX : std_logic_vector(1 downto 0);
	signal rs1_EX : std_logic_vector(4 downto 0);
	signal rs2_EX : std_logic_vector(4 downto 0);
	
	
	-- MEM
	signal mem_read_data : std_logic_vector(31 downto 0) := (others => '0');
	signal flush : std_logic;
	
	signal branch_ctl_MEM : std_logic_vector(2 downto 0);
	signal branch_MEM : std_logic_vector(31 downto 0);
	signal zero_MEM : std_logic;
	signal alu_result_MEM : std_logic_vector(31 downto 0);
	signal rd_MEM : std_logic_vector(4 downto 0);
	signal reg_write_ctl_MEM : std_logic;
	signal mem_to_reg_MEM : std_logic;
	signal forward_mux_b_MEM : std_logic_vector(31 downto 0);
	signal mem_write_ctl_MEM : std_logic_vector(1 downto 0);
    signal mem_read_ctl_MEM : std_logic_vector(1 downto 0);
	signal jump_ctl_MEM : std_logic_vector(1 downto 0);
	signal less_than_MEM : std_logic;
	
	
	-- WB
	signal rd_WB : std_logic_vector(4 downto 0);
	signal reg_write_ctl_WB : std_logic;
	signal mem_to_reg_WB : std_logic;
	signal alu_result_WB : std_logic_vector(31 downto 0);
	signal mem_read_data_WB : std_logic_vector(31 downto 0);
	
	-- DEBUG
	signal id_op : op_t := nop;
	signal ex_op : op_t := nop;
	signal mem_op : op_t := nop;
	signal wb_op : op_t := nop;
	
	
	
	
	
begin
	
	
--
--
-- INSTRUCTION FETCH STAGE (IF)
--
-- 1st stage, instruction memory access, PC update
	
	-- program counter logic
	process(clock, reset)
	begin
		if reset = '1' then
			pc <= (others => '0');
			pc_last <= (others => '0');
		elsif rising_edge(clock) and stall = '0' then
				pc <= pc_next;

		end if;
	end process;
	
	pc_plus4 <=	Std_logic_vector(Unsigned(pc) + 4);
	
	pc_next <=	branch_MEM when branch_taken = '1' or jump_taken = '1' else
			pc_plus4;


	-- instruction memory
	imemory: entity work.imemory(behavioral)
		generic map(
			memory_file  => memory_file,
			imemory_width => imemory_width
		)
		port map(
			clk => clock,
			addr   => pc(imemory_width-1 downto 0),
			data_o => inst_in
		);
		
	
	-- pipeline register IF/ID
	process(clock, reset, flush)
	begin
		if (reset = '1'  or flush = '1') then
			inst_in_ID <= (others => '0');
			pc_ID <= (others => '0');
			pc_plus4_ID <= (others => '0');
		elsif rising_edge(clock) and stall = '0' then
			inst_in_ID <= inst_in;
			pc_ID <= pc;
			pc_plus4_ID <= pc_plus4;
		end if;
	end process;


--
--
-- INSTRUCTION DECODE STAGE (ID)
--
-- 2nd stage, instruction decode, immediate generator, control unit operation, hazard detection unit, register bank access


	-- instruction decode
	opcode <= inst_in_ID(6 downto 0);
	funct3 <= inst_in_ID(14 downto 12);
	funct7 <= inst_in_ID(31 downto 25);
	rd <= inst_in_ID(11 downto 7);
	rs1 <= inst_in_ID(19 downto 15);
	rs2 <= inst_in_ID(24 downto 20);
	imm_i <= ext32(31 downto 12) & inst_in_ID(31 downto 20);
	imm_s <= ext32(31 downto 12) & inst_in_ID(31 downto 25) & inst_in_ID(11 downto 7);
	imm_sb <= ext32(31 downto 13) & inst_in_ID(31) & inst_in_ID(7) & inst_in_ID(30 downto 25) & inst_in_ID(11 downto 8) & '0';
	imm_u <= inst_in_ID(31 downto 12) & x"000";
	imm_uj <= ext32(31 downto 21) & inst_in_ID(31) & inst_in_ID(19 downto 12) & inst_in_ID(20) & inst_in_ID(30 downto 21) & '0';
	ext32 <= (others => '1') when inst_in_ID(31) = '1' else (others => '0');
	
	
	-- immediate generator
	immediate <= imm_i  when opcode = "0010011" or opcode = "0000011" or opcode = "1100111" else -- I
				 imm_s  when opcode = "0100011" else -- S
				 imm_sb when opcode = "1100011" else -- SB
				 imm_u  when opcode = "0100111" or opcode = "0110111" else -- U
				 imm_uj when opcode = "1101111" else -- UJ
				 imm_i;  -- when others   
				
	
	-- control unit
	control_unit: entity work.control
	port map(	
			opcode => opcode,
			funct3 => funct3,
			funct7 => funct7,
			reg_write => reg_write_ctl,
			mem_to_reg => mem_to_reg,
			alu_src1 => alu_src1_ctl,
			alu_src2 => alu_src2_ctl,
			alu_op => alu_op_ctl,
			branch => branch_ctl,
			jump => jump_ctl,
			mem_write => mem_write_ctl,
			mem_read => mem_read_ctl,
			op_debug => id_op
	);
	
	
	-- hazard detection unit
	hazard_unit: entity work.hazard_unit
		port map(
			rs1         => rs1,
			rs2         => rs2,
			rd_EX       => rd_EX,
			mem_read_EX => mem_read_ctl_EX(0),
			stall       => stall
		);

	-- register bank
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
	process(clock, reset, flush)
	begin
		if (reset = '1' or flush = '1') then
			reg_read_data1_EX <= (others => '0');
			reg_read_data2_EX <= (others => '0');
			rd_EX <= (others => '0');
			immediate_EX <= (others => '0');
			pc_EX <= (others => '0');
			pc_plus4_EX <= (others => '0');
			
			alu_src1_ctl_EX <= '0';
			alu_src2_ctl_EX <= (others => '0');
			alu_op_ctl_EX <= (others => '0');
			branch_ctl_EX <= (others => '0');
			jump_ctl_EX <= (others => '0');
			reg_write_ctl_EX <= '0';
			mem_to_reg_EX <= '0';
			mem_read_ctl_EX <= (others => '0');
			mem_write_ctl_EX <= (others => '0');
			
			rs1_EX <= (others => '0');
			rs2_EX <= (others => '0');
			
			ex_op <= nop;
			
		elsif rising_edge(clock) then
			reg_read_data1_EX <= reg_read_data1;
			reg_read_data2_EX <= reg_read_data2;
			rd_EX <= rd;
			immediate_EX <= immediate;
			pc_EX <= pc_ID;
			pc_plus4_EX <= pc_plus4_ID;
			
			-- control signals (hazard mux)
			case stall is
			when '0' =>
				alu_src1_ctl_EX <= alu_src1_ctl;
				alu_src2_ctl_EX <= alu_src2_ctl;
				alu_op_ctl_EX <= alu_op_ctl;
				branch_ctl_EX <= branch_ctl;
				jump_ctl_EX <= jump_ctl;
				reg_write_ctl_EX <= reg_write_ctl;
				mem_to_reg_EX <= mem_to_reg;
				mem_read_ctl_EX <= mem_read_ctl;
				mem_write_ctl_EX <= mem_write_ctl;
				ex_op <= id_op;
			when others =>
				alu_src1_ctl_EX <= '0';
				alu_src2_ctl_EX <= (others => '0');
				alu_op_ctl_EX <= (others => '0');
				branch_ctl_EX <= (others => '0');
				jump_ctl_EX <= (others => '0');
				reg_write_ctl_EX <= '0';
				mem_to_reg_EX <= '0';
				mem_read_ctl_EX <= (others => '0');
				mem_write_ctl_EX <= (others => '0');
				ex_op <= nop;
			end case;
			
			-- forwarding
			rs1_EX <= rs1;
			rs2_EX <= rs2;
		end if;
	end process;


--
--
-- EXECUTION STAGE (EX)
--
-- 3rd stage, ALU operation, forwarding unit operation, branch address computation
	
	
	-- forwarding unit
	forwarding_unit: entity work.forwarding_unit
		port map(
			rs1_EX           => rs1_EX,
			rs2_EX           => rs2_EX,
			rd_MEM        => rd_MEM,
			reg_write_MEM => reg_write_ctl_MEM,
			rd_WB         => rd_WB,
			reg_write_WB  => reg_write_ctl_WB,
			forward_a     => forward_a,
			forward_b     => forward_b
		);
	
	
	-- forwarding muxes
	forward_mux_a <= reg_read_data1_EX when forward_a = "00" else
			alu_result_MEM when forward_a = "01" else
			reg_write_data;	
	forward_mux_b <= reg_read_data2_EX when forward_b = "00" else
			alu_result_MEM when forward_b = "01" else
			reg_write_data;
	
	
	-- ALU input muxes
    alu_src1 <= forward_mux_a when alu_src1_ctl_EX = '0' else
                pc_EX;
    alu_src2 <= forward_mux_b when alu_src2_ctl_EX = "00" else
                immediate_EX when alu_src2_ctl_EX = "01" else
                pc_plus4_EX;
	
	
	-- ALU operation
	alu: entity work.alu
		port map(
			op1       => alu_src1,
			op2       => alu_src2,
			alu_op    => alu_op_ctl_EX,
			result    => alu_result,
			zero      => zero,
			less_than => less_than
		);
	
	
	-- branch address computation
	branch_src1 <= reg_read_data1_EX when jump_ctl_EX(1) = '1' else pc_EX;
	branch_src2 <= immediate_EX;
	branch <= Std_logic_vector(Unsigned(branch_src1) + Unsigned(branch_src2));
	
	
	-- pipeline register EX/MEM
	process(clock, reset)
	begin
		if reset = '1' then
		    alu_result_MEM <= (others => '0');
			branch_MEM <= (others => '0');
			zero_MEM <= '0';
			branch_ctl_MEM <= (others => '0');
			rd_MEM <= (others => '0');
			forward_mux_b_MEM <= (others => '0');
			reg_write_ctl_MEM <= '0';
			mem_to_reg_MEM <= '0';
			mem_read_ctl_MEM <= (others => '0');
            mem_write_ctl_MEM <= (others => '0');
            jump_ctl_MEM <= (others => '0');
            less_than_MEM <= '0';
            mem_op <= nop;
		elsif rising_edge(clock) then
		    alu_result_MEM <= alu_result;
			branch_MEM <= branch;
			zero_MEM <= zero;
			branch_ctl_MEM <= branch_ctl_EX;
			rd_MEM <= rd_EX;
			forward_mux_b_MEM <= forward_mux_b;
			reg_write_ctl_MEM <= reg_write_ctl_EX;
			mem_to_reg_MEM <= mem_to_reg_EX;
			mem_read_ctl_MEM <= mem_read_ctl_EX;
            mem_write_ctl_MEM <= mem_write_ctl_EX;
            jump_ctl_MEM <= jump_ctl_EX;
            less_than_MEM <= less_than;
            mem_op <= ex_op;
		end if;
	end process;
	

--
--
-- MEMORY ACESS STAGE (MEM)
--
-- 4th stage, data memory access, branch and jump decisions logic
	
	-- branch and jump decisions logic
	branch_taken <= '1' when (zero_MEM = '1' and branch_ctl_MEM = "001") or						-- BEQ
				(zero_MEM = '0' and branch_ctl_MEM = "010") or						-- BNE
				(less_than_MEM = '1' and branch_ctl_MEM = "011") or						-- BLT
				(less_than_MEM = '0' and branch_ctl_MEM = "100") or						-- BGE
				(less_than_MEM = '1' and branch_ctl_MEM = "101") or						-- BLTU
				(less_than_MEM = '0' and branch_ctl_MEM = "110")						-- BGEU
				else '0';
	jump_taken <= '1' when jump_ctl_MEM(0) = '1' else '0';
	flush <= '1' when branch_taken = '1' or jump_taken = '1' else '0';
	
	
	-- data memory access
	dmemory: entity work.dmemory
	    generic map(
	        dmemory_width => dmemory_width
	    )
	    port map(
	        clk        => clock,
	        mem_write  => mem_write_ctl_MEM(0),
	        write_byte => mem_write_ctl_MEM(1),
	        mem_read   => mem_read_ctl_MEM(0),
	        read_byte   => mem_read_ctl_MEM(1),
	        addr       => alu_result_MEM(dmemory_width-1 downto 0),
	        write_data => forward_mux_b_MEM,
	        read_data  => mem_read_data
	    );

	 
	-- pipeline register MEM/WB
    process(clock, reset)
    begin
        if reset = '1' then
            mem_read_data_WB <= (others => '0');
            alu_result_WB <= (others => '0');
            rd_WB <= (others => '0');
            reg_write_ctl_WB <= '0';
            mem_to_reg_WB <= '0';
            wb_op <= nop;
        elsif rising_edge(clock) then
            mem_read_data_WB <= mem_read_data;
            alu_result_WB <= alu_result_MEM;
            rd_WB <= rd_MEM;
            reg_write_ctl_WB <= reg_write_ctl_MEM;
            mem_to_reg_WB <= mem_to_reg_MEM;
            wb_op <= mem_op;
        end if;
    end process;
    
    
--
--
-- WRITE BACK STAGE (WB)
--
-- 5th stage, write back
	
	-- write back
	reg_write_data <=  mem_read_data_WB when  mem_to_reg_WB = '1' else
	                   alu_result_WB;
	
	debug <= '0' when reg_write_data(0) = '0' else '1';
	
end architecture RTL;
