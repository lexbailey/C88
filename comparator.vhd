library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity comparator is
    Port ( a : in  STD_LOGIC_VECTOR (7 downto 0);
           b : in  STD_LOGIC_VECTOR (7 downto 0);
           c : out  STD_LOGIC;
           mode : in  STD_LOGIC_VECTOR (1 downto 0));
end comparator;

architecture Behavioral of comparator is

	signal a_un : signed (7 downto 0);
	signal b_un : signed (7 downto 0);

	constant MODE_GREATER : std_logic_vector(1 downto 0) := "00";
	constant MODE_LESS : std_logic_vector(1 downto 0) := "01";
	constant MODE_EQUAL : std_logic_vector(1 downto 0) := "10";
	constant MODE_INEQUAL : std_logic_vector(1 downto 0) := "11";	

begin

	a_un <= signed(a);
	b_un <= signed(b);

	process (mode, a_un, b_un) begin
		case mode is
			when MODE_GREATER =>
				if b_un > a_un then
					c <= '1';
				else
					c <= '0';
				end if;
			when MODE_LESS =>
				if b_un < a_un then
					c <= '1';
				else
					c <= '0';
				end if;
			when MODE_EQUAL =>
				if b_un = a_un then
					c <= '1';
				else
					c <= '0';
				end if;				
			when MODE_INEQUAL =>
				if b_un /= a_un then
					c <= '1';
				else
					c <= '0';
				end if;
			when others =>
				c <= '0';
		end case;
	end process;

end Behavioral;

