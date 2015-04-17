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
	
	signal display: cell_select_array;
	
	signal miso: std_logic;
begin

	Inst_DataPath: DataPath PORT MAP(
		clk => clk,
		rst => rst,
		run => run,
		step => step,
		display => display,
		user_mode => user_mode,
		user_addr => user_addr,
		user_data => user_data,
		user_write => user_write,
		io_output => gpoutput,
		io_input => gpinput
	);

	Inst_matrix_driver: matrix_driver PORT MAP(
		clk => clk,
		rst => rst,
		MOSI => MOSI,
		MISO => miso,
		SS => SS,
		SCK => SCK,
		Matrix_data => display
	);

end Behavioral;

