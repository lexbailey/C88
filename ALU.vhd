library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( inputA : in  STD_LOGIC_VECTOR (7 downto 0);
           inputB : in  STD_LOGIC_VECTOR (7 downto 0);
           operation : in  STD_LOGIC_VECTOR (3 downto 0);
           output : out  STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is

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

begin

	process (operation, inputA, inputB) begin
		case operation is
			when OP_ADD =>
				output <= std_logic_vector(resize(signed(inputA) + signed(inputB),8));
			when OP_SUB =>
				output <= std_logic_vector(resize(signed(inputA) - signed(inputB),8));
			when OP_MUL =>
				output <= std_logic_vector(resize(signed(inputA) * signed(inputB),8));
			--when OP_DIV =>
			--	output <= std_logic_vector(resize(signed(inputA) / signed(inputB),8));
				
			when OP_ADDU =>
				output <= std_logic_vector(resize(unsigned(inputA) + unsigned(inputB),8));
			when OP_SUBU =>
				output <= std_logic_vector(resize(unsigned(inputA) - unsigned(inputB),8));
			when OP_MULU =>
				output <= std_logic_vector(resize(unsigned(inputA) * unsigned(inputB),8));
			--when OP_DIVU =>
			--	output <= std_logic_vector(resize(unsigned(inputA) / unsigned(inputB),8));
				
			when OP_INC =>
				output <= std_logic_vector(resize(signed(inputA) + 1, 8));
			when OP_DEC =>
				output <= std_logic_vector(resize(signed(inputA) - 1, 8));
			when OP_DOUBLE =>
				output <= std_logic_vector(resize(signed(inputA) * 2, 8));
			when OP_HALF =>
				output <= std_logic_vector(resize(signed(inputA) / 2, 8));
				
			when OP_SHL =>
				output <= std_logic_vector(resize(unsigned(inputA) sll to_integer(unsigned(inputB)), 8));
			when OP_SHR =>
				output <= std_logic_vector(resize(unsigned(inputA) srl to_integer(unsigned(inputB)), 8));
			when OP_ROL =>
				output <= std_logic_vector(resize(unsigned(inputA) rol to_integer(unsigned(inputB)), 8));
			when OP_ROR =>
				output <= std_logic_vector(resize(unsigned(inputA) ror to_integer(unsigned(inputB)), 8));
			when others =>
				output <= "00000000";
		end case;
	end process;

end Behavioral;

