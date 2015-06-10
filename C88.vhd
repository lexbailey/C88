library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.types_package.all;

entity C88 is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           user_mode : in  STD_LOGIC;
           user_write : in  STD_LOGIC;
           user_data : in  STD_LOGIC_VECTOR (7 downto 0);
           user_addr : in  STD_LOGIC_VECTOR (2 downto 0);
           gpinput : in  STD_LOGIC_VECTOR (7 downto 0);
           gpoutput : out  STD_LOGIC_VECTOR (7 downto 0);
           step : in  STD_LOGIC;
           run : in  STD_LOGIC;
			  MOSI: out STD_LOGIC;
			  SCK: out STD_LOGIC;
			  SS: out STD_LOGIC;
			  
			  is_clock_slow: in STD_LOGIC;
			  is_clock_full: in STD_LOGIC;
			  view_pc: in STD_LOGIC;
			  view_reg: in STD_LOGIC);
end C88;

architecture Behavioral of C88 is

	type ClockMode is (SLOW_cm, FAST_cm, FULL_cm);
	type ViewMode is (PC_vm, MEM_vm, REG_vm);
	
	signal clock_mode : ClockMode;
	signal view_mode : ViewMode;

	COMPONENT DataPath
	PORT(
		clk : IN std_logic;
		enable : in STD_LOGIC;
		rst : IN std_logic;
		run : IN std_logic;
		step : IN std_logic;
		user_mode : IN std_logic;
		user_addr : IN std_logic_vector(2 downto 0);
		user_data : IN std_logic_vector(7 downto 0);
		user_write : IN std_logic;
		io_input : IN std_logic_vector(7 downto 0);          
		display_mem : out cell_select_array;
		display_pc : out cell_select_array;
		display_reg : out cell_select_array;
		io_output : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT matrix_driver
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		MISO : IN std_logic;
		Matrix_data : IN cell_select_array;          
		MOSI : OUT std_logic;
		SS : OUT std_logic;
		SCK : OUT std_logic
		);
	END COMPONENT;
	
	
	COMPONENT Debouncer
	GENERIC(
		CLK_DIV : natural;
		CHECK_BITS : natural
		);
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		sig : IN std_logic;          
		deb_sig : OUT std_logic
		);
	END COMPONENT;
	
	signal display: cell_select_array;
	
	signal display_mem: cell_select_array;
	signal display_pc: cell_select_array;
	signal display_reg: cell_select_array;
	
	signal miso: std_logic;
	
	signal deb_User: std_logic;
	signal deb_Write: std_logic;
	signal deb_Step: std_logic;
	signal deb_Reset: std_logic;
	signal deb_Run: std_logic;
	
	signal deb_Data: std_logic_vector(7 downto 0);
	signal deb_Addr: std_logic_vector(2 downto 0);
	
	--full clock is 
	signal slow_clock: std_logic; -- 100hz
	signal fast_clock: std_logic; -- 1000hz
	
	signal clock_counter: std_logic_vector(14 downto 0);
	signal slow_clock_counter: std_logic_vector(6 downto 0);
	
	signal enable: std_logic;
	
begin

	--clock divider
	process(clk) begin
		if (rising_edge(clk)) then
			if deb_Reset = '1' then
				clock_counter <= (others =>'0');
				fast_clock <= '0';
				
				slow_clock_counter <= (others => '0');
				slow_clock <= '0';
			else
				if clock_counter = "111110100000000" then
					clock_counter <= (others =>'0');
					fast_clock <= '1';
					
					if slow_clock_counter = "1100100" then
						slow_clock_counter <= (others => '0');
						slow_clock <= '1';
					else
						slow_clock_counter <= std_logic_vector(unsigned(slow_clock_counter) + 1);
						slow_clock <= '0';
					end if;
					
				else
					clock_counter <= std_logic_vector(unsigned(clock_counter) + 1);
					fast_clock <= '0';
					slow_clock <= '0';
				end if;
			end if;
		end if;
	end process;
		
	enable <= '1' when (clock_mode = FULL_cm)
				else slow_clock when (clock_mode = SLOW_cm)
				else fast_clock;
	
	clock_mode <= SLOW_cm when is_clock_slow = '1'
			else FULL_cm when is_clock_full = '1'
			else FAST_cm;
			
	view_mode <= PC_vm when view_pc = '1'
			else REG_vm when view_reg = '1'
			else MEM_vm;
	
	--Display (view) selector
	display <= display_reg when view_mode = REG_vm
			else display_pc when view_mode = PC_vm
			else display_mem;

	Inst_DataPath: DataPath PORT MAP(
		clk => clk,
		enable => enable,
		rst => deb_Reset,
		run => deb_Run,
		step => deb_Step,
		display_mem => display_mem,
		display_pc => display_pc,
		display_reg => display_reg,
		user_mode => deb_User,
		user_addr => deb_Addr,
		user_data => deb_Data,
		user_write => deb_Write,
		io_output => gpoutput,
		io_input => gpinput
	);

	Inst_matrix_driver: matrix_driver PORT MAP(
		clk => clk,
		rst => deb_Reset,
		MOSI => MOSI,
		MISO => miso,
		SS => SS,
		SCK => SCK,
		Matrix_data => display
	);
	
	write_Debouncer: Debouncer GENERIC MAP (150,214) PORT MAP(
		clk => clk,
		rst => deb_Reset,
		sig => user_write,
		deb_sig => deb_Write
	);
	
	step_Debouncer: Debouncer GENERIC MAP (150,214) PORT MAP(
		clk => clk,
		rst => deb_Reset,
		sig => step,
		deb_sig => deb_Step
	);
	
	reset_Debouncer: Debouncer GENERIC MAP (150,214) PORT MAP(
		clk => clk,
		rst => '0',
		sig => rst,
		deb_sig => deb_Reset
	);

	user_Debouncer: Debouncer GENERIC MAP (150,214) PORT MAP(
		clk => clk,
		rst => deb_Reset,
		sig => user_mode,
		deb_sig => deb_User
	);
	
	run_Debouncer: Debouncer GENERIC MAP (150,214) PORT MAP(
		clk => clk,
		rst => deb_Reset,
		sig => run,
		deb_sig => deb_Run
	);
	
	dataDebouncers: for I in 0 to 7 generate
		data_Debouncer: Debouncer GENERIC MAP (150,214) PORT MAP(
			clk => clk,
			rst => deb_Reset,
			sig => user_data(I),
			deb_sig => deb_Data(I)
		);
	end generate;
	
	addrDebouncers: for I in 0 to 2 generate
		addr_Debouncer: Debouncer GENERIC MAP (150,214) PORT MAP(
			clk => clk,
			rst => deb_Reset,
			sig => user_Addr(I),
			deb_sig => deb_Addr(I)
		);
	end generate;

end Behavioral;

