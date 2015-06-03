library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
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
			  SS: out STD_LOGIC);
end C88;

architecture Behavioral of C88 is

	COMPONENT DataPath
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		run : IN std_logic;
		step : IN std_logic;
		user_mode : IN std_logic;
		user_addr : IN std_logic_vector(2 downto 0);
		user_data : IN std_logic_vector(7 downto 0);
		user_write : IN std_logic;
		io_input : IN std_logic_vector(7 downto 0);          
		display : OUT cell_select_array;
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
	
	signal miso: std_logic;
	
	signal deb_User: std_logic;
	signal deb_Write: std_logic;
	signal deb_Step: std_logic;
	signal deb_Reset: std_logic;
	signal deb_Run: std_logic;
	
	signal deb_Data: std_logic_vector(7 downto 0);
	signal deb_Addr: std_logic_vector(2 downto 0);
	
begin

	Inst_DataPath: DataPath PORT MAP(
		clk => clk,
		rst => deb_Reset,
		run => deb_Run,
		step => deb_Step,
		display => display,
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
		rst => rst,
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

