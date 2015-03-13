library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity decode_3_to_8 is
    Port ( input : in  STD_LOGIC_VECTOR (2 downto 0);
           output : out  STD_LOGIC_VECTOR (7 downto 0));
end decode_3_to_8;

architecture Behavioral of decode_3_to_8 is

begin

	output <=	"00000001" when input = "000"
			else	"00000010" when input = "001"
			else	"00000100" when input = "010"
			else	"00001000" when input = "011"
			else	"00010000" when input = "100"
			else	"00100000" when input = "101"
			else	"01000000" when input = "110"
			else	"10000000" when input = "111";

end Behavioral;

