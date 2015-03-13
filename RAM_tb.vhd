LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY RAM_tb IS
END RAM_tb;
 
ARCHITECTURE behavior OF RAM_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RAM
    PORT(
         clk : IN  std_logic;
         addr : IN  std_logic_vector(2 downto 0);
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0);
         wen : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal addr : std_logic_vector(2 downto 0) := (others => '0');
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal wen : std_logic := '0';

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RAM PORT MAP (
          clk => clk,
          addr => addr,
          data_in => data_in,
          data_out => data_out,
          wen => wen
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

      wen <= '0';
		addr <= "000";
		data_in <= "00000000";
		wait for clk_period*10;
		data_in <= "10101010";
		wen <= '1';
		wait for clk_period*1;
		wen <= '0';
		wait for clk_period*1;
		
      addr <= "110";
		data_in <= "00000000";
		wait for clk_period*10;
		data_in <= "10101010";
		wen <= '1';
		wait for clk_period*1;
		wen <= '0';
		wait for clk_period*1;

      wait;
   end process;

END;
