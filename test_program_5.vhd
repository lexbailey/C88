LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.types_package.all;
 
ENTITY test_program_5 IS
END test_program_5;
 
ARCHITECTURE behavior OF test_program_5 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DataPath
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         run : IN  std_logic;
         step : IN  std_logic;
         display : OUT  cell_select_array;
         user_mode : IN  std_logic;
         user_addr : IN  std_logic_vector(2 downto 0);
         user_data : IN  std_logic_vector(7 downto 0);
         user_write : IN  std_logic;
			io_output : out std_logic_vector (7 downto 0);
			io_input : in std_logic_vector (7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal run : std_logic := '0';
   signal step : std_logic := '0';
   signal user_mode : std_logic := '0';
   signal user_addr : std_logic_vector(2 downto 0) := (others => '0');
   signal user_data : std_logic_vector(7 downto 0) := (others => '0');
   signal user_write : std_logic := '0';
	signal io_output : std_logic_vector (7 downto 0) := (others => '0');
	signal io_input : std_logic_vector (7 downto 0) := (others => '0');

 	--Outputs
   signal display : cell_select_array;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
	--
	constant test_program: cell_select_array := (
		"00000111",
		"01100000",
		"01111000",
		"00000110",
		"01110000",
		"00011000",
		"00110000",
		"10001010"
	);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DataPath PORT MAP (
          clk => clk,
          rst => rst,
          run => run,
          step => step,
          display => display,
          user_mode => user_mode,
          user_addr => user_addr,
          user_data => user_data,
          user_write => user_write,
			 io_output => io_output,
			 io_input => io_input
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	


		run <= '0';
		step <= '0';
		user_mode <= '0';
		user_addr <= (others => '0');
		user_data <= (others => '0');
		user_write <= '0';
		io_input <= "10101010";

		rst <= '1';
      wait for clk_period*10;
		rst <= '0';
		user_mode <= '1';
		
		for i in 0 to 7 loop
      	
			user_addr <= std_logic_vector(to_unsigned(i, 3));
			user_data <= test_program(i);
			user_write <= '1';
			wait for clk_period;
			user_write <= '0';
			wait for clk_period;
		
		end loop;
		
		user_mode <= '0';
		wait for clk_period;
		run <= '1';

      wait;
   end process;

END;
