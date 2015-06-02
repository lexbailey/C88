--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:10:58 06/02/2015
-- Design Name:   
-- Module Name:   /home/daniel/C88/Debouncer_tb.vhd
-- Project Name:  C88
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Debouncer
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Debouncer_tb IS
END Debouncer_tb;
 
ARCHITECTURE behavior OF Debouncer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Debouncer
	 generic(	CLK_DIV : natural;
					CHECK_BITS : natural
			);
    PORT(
         clk : IN  std_logic;
			rst : IN  std_logic;
         sig : IN  std_logic;
         deb_sig : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
	signal rst : std_logic := '0';
   signal sig : std_logic := '0';

 	--Outputs
   signal deb_sig : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Debouncer
			GENERIC MAP (4,8)
			PORT MAP (
			 rst => rst,
          clk => clk,
          sig => sig,
          deb_sig => deb_sig
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
		rst <= '1';
		wait for clk_period;
		rst <= '0';
      wait for clk_period*10;

      sig <= '1';
		wait for clk_period;
		sig <= '0';
		wait for clk_period;
		
		sig <= '1';
		wait for clk_period;
		sig <= '0';
		wait for clk_period;
		
		sig <= '1';
		wait for clk_period;
		sig <= '0';
		wait for clk_period;
		
		sig <= '1';
		wait for clk_period;
		sig <= '0';
		wait for clk_period;
		
		sig <= '1';
		wait for clk_period*10;
		sig <= '0';
		wait for clk_period*10;
		
		sig <= '1';
		wait for clk_period*10;
		sig <= '0';
		wait for clk_period*10;
		
		sig <= '1';
		wait for clk_period*10;
		sig <= '0';
		wait for clk_period*10;
		
		sig <= '1';
		wait for clk_period*10;
		sig <= '0';
		wait for clk_period*10;
		
		sig <= '1';
		wait for clk_period*10;
		sig <= '0';
		wait for clk_period*10;
		
		sig <= '1';
		wait for clk_period*100;
		sig <= '0';
		wait for clk_period*100;
		
		
		sig <= '1';
		wait for clk_period*100;
		sig <= '0';
		wait for clk_period*100;
		
		
		sig <= '1';
		wait for clk_period*100;
		sig <= '0';
		wait for clk_period*100;
		
		
		sig <= '1';
		wait for clk_period*100;
		sig <= '0';
		wait for clk_period*100;

      wait;
   end process;

END;
