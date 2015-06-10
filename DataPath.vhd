library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types_package.all;

entity DataPath is
    Port ( clk : in  STD_LOGIC;
			  enable : in STD_LOGIC;
           rst : in  STD_LOGIC;
           run : in  STD_LOGIC;
           step : in  STD_LOGIC;
			  display_mem : out cell_select_array;
			  display_pc : out cell_select_array;
			  display_reg : out cell_select_array;
			  user_mode : in STD_LOGIC;
			  user_addr : in STD_LOGIC_VECTOR (2 downto 0);
			  user_data : in STD_LOGIC_VECTOR (7 downto 0);
			  user_write : in STD_LOGIC;
			  io_output : out std_logic_vector (7 downto 0);
			  io_input : in std_logic_vector (7 downto 0));
end DataPath;

architecture Behavioral of DataPath is

	COMPONENT RAM
	PORT(
		clk : IN std_logic;
		addr : IN std_logic_vector(2 downto 0);
		data_in : IN std_logic_vector(7 downto 0);
		wen : IN std_logic;          
		data_out : OUT std_logic_vector(7 downto 0);
		display_out : OUT cell_select_array
		);
	END COMPONENT;

	COMPONENT InstructionDecoder
	PORT(
		opcode : IN std_logic_vector(7 downto 0);          
		addr : OUT std_logic_vector(2 downto 0);
		ALU_op : OUT std_logic_vector(3 downto 0);
		COMP_op : OUT std_logic_vector(1 downto 0);
		reg_wen : OUT std_logic;
		ram_wen : OUT std_logic;
		stop : OUT std_logic;
		is_jump : OUT std_logic;
		jump_type : OUT std_logic;
		reg_input_select : OUT std_logic;
		is_test : OUT std_logic;
		is_iow : OUT std_logic;
		is_io_in : OUT std_logic;
		io_reg_in_sel: OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT ALU
	PORT(
		inputA : IN std_logic_vector(7 downto 0);
		inputB : IN std_logic_vector(7 downto 0);
		Baddr : IN  STD_LOGIC_VECTOR (2 downto 0);
		operation : IN std_logic_vector(3 downto 0);          
		output : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	COMPONENT PC
	PORT(
		clk : IN std_logic;
		inc : IN std_logic;
		rst : IN std_logic;
		PCIn : IN std_logic_vector(2 downto 0);
		jmp : IN std_logic;          
		PCOut : OUT std_logic_vector(2 downto 0)
		);
	END COMPONENT;
	
	COMPONENT Control
	PORT(
		clk : IN std_logic;
		enable : in STD_LOGIC;
		run : IN std_logic;
		step : IN std_logic;
		stop : IN std_logic;
		skip : IN std_logic;
		is_jump : IN std_logic;
		rst : IN std_logic;          
		ram_addr_sel : OUT std_logic;
		is_exec : OUT std_logic;
		instr_reg_wen : OUT std_logic;
		pc_inc : OUT std_logic;
		pc_load : OUT std_logic
		);
	END COMPONENT;


	COMPONENT register_8
	PORT(
		clk : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		wen : IN std_logic;
		rst : IN std_logic;          
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT comparator
	PORT(
		a : IN std_logic_vector(7 downto 0);
		b : IN std_logic_vector(7 downto 0);
		mode : IN std_logic_vector(1 downto 0);          
		c : OUT std_logic
		);
	END COMPONENT;
	
	signal RAM_Addr: std_logic_vector(2 downto 0);
	signal sys_Addr: std_logic_vector(2 downto 0);
	signal RAM_Addr_PC: std_logic_vector(2 downto 0);
	signal RAM_Addr_DECODE: std_logic_vector(2 downto 0);
	signal RAM_Addr_DATA_TAP: std_logic_vector(2 downto 0);
	signal RAM_Data_Out: std_logic_vector(7 downto 0);
	signal RAM_Data_In: std_logic_vector(7 downto 0);
	
	signal PC_in: std_logic_vector(2 downto 0);
	
	signal main_reg_in: std_logic_vector(7 downto 0);
	signal main_reg_out: std_logic_vector(7 downto 0);

	signal instr_reg_in: std_logic_vector(7 downto 0);
	signal instr_reg_out: std_logic_vector(7 downto 0);
	
	signal ALU_Result: std_logic_vector(7 downto 0);
	
	signal ALU_op: std_logic_vector(3 downto 0);
	
	signal ram_sel: std_logic;
	
	signal reg_input_select: std_logic;
	
	signal stop: std_logic;
	
	signal ram_wen: std_logic;
	signal sys_ram_wen: std_logic;
	signal is_exec: std_logic;
	signal main_reg_wen: std_logic;
	
	signal dec_ram_wen: std_logic;
	signal dec_main_reg_wen: std_logic;
	
	signal instr_reg_wen: std_logic;
	
	signal is_jump: std_logic;
	signal jump_type: std_logic;
	
	signal pc_inc: std_logic;
	signal pc_load: std_logic;
	
	signal test_pass: std_logic;
	
	signal is_test: std_logic;
	
	signal do_skip : std_logic;
	
	signal comp_op : std_logic_vector(1 downto 0);
	
	signal io_out_data: std_logic_vector(7 downto 0);
	
	signal dec_io_out_reg_wen: std_logic;
	
	signal io_out_reg_wen: std_logic;

	signal io_reg_in_sel: std_logic;
	
	signal is_io_in: std_logic;
	
	signal PC_to8 : std_logic_vector(7 downto 0);
	
begin

	

	Inst_RAM: RAM PORT MAP(
		clk => clk,
		addr => RAM_Addr,
		data_in => RAM_Data_In,
		data_out => RAM_Data_Out,
		wen => ram_wen,
		display_out => display_mem
	);
	
	PC_to8(7 downto 3) <= (others => '0');
	PC_to8(2 downto 0) <= RAM_Addr_PC;
	
	display_pc(0) <= PC_to8;
	display_pc(1) <= PC_to8;
	display_pc(2) <= PC_to8;
	display_pc(3) <= PC_to8;
	display_pc(4) <= PC_to8;
	display_pc(5) <= PC_to8;
	display_pc(6) <= PC_to8;
	display_pc(7) <= PC_to8;
	
	display_reg(0) <= main_reg_out;
	display_reg(1) <= main_reg_out;
	display_reg(2) <= main_reg_out;
	display_reg(3) <= main_reg_out;
	display_reg(4) <= main_reg_out;
	display_reg(5) <= main_reg_out;
	display_reg(6) <= main_reg_out;
	display_reg(7) <= main_reg_out;
	
	RAM_Data_in <= user_data when user_mode = '1'
			else main_reg_out;
	
	RAM_Addr <= user_addr when user_mode = '1'
			else sys_addr;
	
	sys_Addr <= RAM_Addr_PC when ram_sel = '0'
			else RAM_addr_DECODE;
	
	Inst_InstructionDecoder: InstructionDecoder PORT MAP(
		opcode => instr_reg_out,
		addr => RAM_Addr_DECODE,
		ALU_op => ALU_op,
		COMP_op => comp_op,
		reg_wen => dec_main_reg_wen,
		ram_wen => dec_ram_wen,
		stop => stop,
		is_jump => is_jump,
		jump_type => jump_type,
		reg_input_select => reg_input_select,
		is_test => is_test,
		is_iow => dec_io_out_reg_wen,
		is_io_in => is_io_in,
		io_reg_in_sel => io_reg_in_sel
	);
	
	main_reg_wen <= '1' when is_exec = '1' and dec_main_reg_wen = '1'
				else '0';
	sys_ram_wen <= '1' when is_exec = '1' and dec_ram_wen = '1'
				else '0';
				
	ram_wen <= user_write when user_mode = '1'
				else sys_ram_wen;

	Inst_ALU: ALU PORT MAP(
		inputA => main_reg_out,
		inputB => RAM_Data_out,
		Baddr => RAM_Addr_DECODE,
		operation => ALU_op,
		output => ALU_Result
	);
	
	Inst_comparator: comparator PORT MAP(
		a => main_reg_out,
		b => RAM_Data_out,
		c => test_pass,
		mode => comp_op
	);
	
	do_skip <= '1' when test_pass = '1' and is_test = '1'
			else '0';
	
	Inst_PC: PC PORT MAP(
		clk => clk,
		inc => pc_inc,
		rst => rst,
		PCOut => RAM_Addr_PC,
		PCIn => PC_in,
		jmp => pc_load
	);
	
	RAM_Addr_DATA_TAP <= RAM_Data_out(2 downto 0);
	
	PC_in <= RAM_Addr_DATA_TAP when jump_type = '1'
			else RAM_Addr_DECODE;
	
	Inst_Control: Control PORT MAP(
		clk => clk,
		enable => enable,
		run => run,
		step => step,
		stop => stop,
		skip => do_skip,
		is_jump => is_jump,
		rst => rst,
		ram_addr_sel => ram_sel,
		is_exec => is_exec,
		instr_reg_wen => instr_reg_wen,
		pc_inc => pc_inc,
		pc_load => pc_load
	);	
	
	main_register: register_8 PORT MAP(
		clk => clk,
		data_in => main_reg_in,
		data_out => main_reg_out,
		wen => main_reg_wen,
		rst => rst
	);
	
	--Bodge mux. Selects either GPIO input, RAM out or ALU result
	main_reg_in <= io_input when is_io_in = '1'
				else RAM_data_out when reg_input_select = '1'
				else ALU_Result;
	
	instruction_register: register_8 PORT MAP(
		clk => clk,
		data_in => instr_reg_in,
		data_out => instr_reg_out,
		wen => instr_reg_wen,
		rst => rst
	);
	
	instr_reg_in <= RAM_Data_Out;
	
	
	gpio_output_register: register_8 PORT MAP(
		clk => clk,
		data_in => io_out_data,
		data_out => io_output,
		wen => io_out_reg_wen,
		rst => rst
	);
	
	io_out_reg_wen <= '1' when is_exec = '1' and dec_io_out_reg_wen = '1'
				else '0';
	
	io_out_data <= "00000000" when io_reg_in_sel = '1'
			else main_reg_out;
	
end Behavioral;

