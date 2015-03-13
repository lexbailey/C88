library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types_package.all;

entity DataPath is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           run : in  STD_LOGIC;
           step : in  STD_LOGIC;
			  display : out cell_select_array;
			  user_mode : in STD_LOGIC;
			  user_addr : in STD_LOGIC_VECTOR (2 downto 0);
			  user_data : in STD_LOGIC_VECTOR (7 downto 0);
			  user_write : in STD_LOGIC);
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
		reg_wen : OUT std_logic;
		ram_wen : OUT std_logic;
		stop : OUT std_logic;
		is_jump : OUT std_logic;
		jump_type : OUT std_logic;
		reg_input_select : OUT std_logic
		);
	END COMPONENT;

	COMPONENT ALU
	PORT(
		inputA : IN std_logic_vector(7 downto 0);
		inputB : IN std_logic_vector(7 downto 0);
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
		run : IN std_logic;
		step : IN std_logic;
		stop : IN std_logic;
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
	
begin

	Inst_RAM: RAM PORT MAP(
		clk => clk,
		addr => RAM_Addr,
		data_in => RAM_Data_In,
		data_out => RAM_Data_Out,
		wen => ram_wen,
		display_out => display
	);
	
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
		reg_wen => dec_main_reg_wen,
		ram_wen => dec_ram_wen,
		stop => stop,
		is_jump => is_jump,
		jump_type => jump_type,
		reg_input_select => reg_input_select
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
		operation => ALU_op,
		output => ALU_Result
	);
	
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
		run => run,
		step => step,
		stop => stop,
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
	
	main_reg_in <= RAM_data_out when reg_input_select = '1'
				else ALU_Result;
	
	instruction_register: register_8 PORT MAP(
		clk => clk,
		data_in => instr_reg_in,
		data_out => instr_reg_out,
		wen => instr_reg_wen,
		rst => rst
	);
	
	instr_reg_in <= RAM_Data_Out;
	
end Behavioral;

