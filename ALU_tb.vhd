LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ALU_tb IS
END ALU_tb;
 
ARCHITECTURE behavior OF ALU_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         inputA : IN  std_logic_vector(7 downto 0);
         inputB : IN  std_logic_vector(7 downto 0);
         operation : IN  std_logic_vector(3 downto 0);
         output : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal inputA : std_logic_vector(7 downto 0) := (others => '0');
   signal inputB : std_logic_vector(7 downto 0) := (others => '0');
   signal operation : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(7 downto 0);
	
	constant OP_ADD: std_logic_vector(3 downto 0) := "0000";
	constant OP_SUB: std_logic_vector(3 downto 0) := "0001";
	constant OP_MUL: std_logic_vector(3 downto 0) := "0010";
	constant OP_DIV: std_logic_vector(3 downto 0) := "0011";

	constant OP_SHL: std_logic_vector(3 downto 0) := "0100";
	constant OP_SHR: std_logic_vector(3 downto 0) := "0101";
	constant OP_ROL: std_logic_vector(3 downto 0) := "0110";
	constant OP_ROR: std_logic_vector(3 downto 0) := "0111";

	constant OP_ADDU: std_logic_vector(3 downto 0) := "1000";
	constant OP_SUBU: std_logic_vector(3 downto 0) := "1001";
	constant OP_MULU: std_logic_vector(3 downto 0) := "1010";
	constant OP_DIVU: std_logic_vector(3 downto 0) := "1011";

	constant OP_INC: std_logic_vector(3 downto 0) := "1100";
	constant OP_DEC: std_logic_vector(3 downto 0) := "1101";
	constant OP_DOUBLE: std_logic_vector(3 downto 0) := "1110";
	constant OP_HALF: std_logic_vector(3 downto 0) := "1111";
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          inputA => inputA,
          inputB => inputB,
          operation => operation,
          output => output
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      inputA <= "00001100"; --12
		inputB <= "00000100"; --4
		operation <= OP_ADD;
		wait for 10 ns;
		operation <= OP_SUB;
		wait for 10 ns;
		operation <= OP_MUL;
		wait for 10 ns;
		operation <= OP_DIV;
		wait for 10 ns;
		
		operation <= OP_ADDU;
		wait for 10 ns;
		operation <= OP_SUBU;
		wait for 10 ns;
		operation <= OP_MULU;
		wait for 10 ns;
		operation <= OP_DIVU;
		wait for 10 ns;
		
		operation <= OP_SHL;
		wait for 10 ns;
		operation <= OP_SHR;
		wait for 10 ns;
		operation <= OP_ROL;
		wait for 10 ns;
		operation <= OP_ROR;
		wait for 10 ns;
		
		operation <= OP_INC;
		wait for 10 ns;
		operation <= OP_DEC;
		wait for 10 ns;
		operation <= OP_DOUBLE;
		wait for 10 ns;
		operation <= OP_HALF;
		wait for 10 ns;
		
		
		inputA <= "11111110"; --  -2 or +254
		inputB <= "00000100"; --4
		operation <= OP_ADD;
		wait for 10 ns;
		operation <= OP_SUB;
		wait for 10 ns;
		operation <= OP_MUL;
		wait for 10 ns;
		operation <= OP_DIV;
		wait for 10 ns;
		
		operation <= OP_ADDU;
		wait for 10 ns;
		operation <= OP_SUBU;
		wait for 10 ns;
		operation <= OP_MULU;
		wait for 10 ns;
		operation <= OP_DIVU;
		wait for 10 ns;
		
		operation <= OP_SHL;
		wait for 10 ns;
		operation <= OP_SHR;
		wait for 10 ns;
		operation <= OP_ROL;
		wait for 10 ns;
		operation <= OP_ROR;
		wait for 10 ns;
		
		operation <= OP_INC;
		wait for 10 ns;
		operation <= OP_DEC;
		wait for 10 ns;
		operation <= OP_DOUBLE;
		wait for 10 ns;
		operation <= OP_HALF;
		wait for 10 ns;

      wait;
   end process;

END;
