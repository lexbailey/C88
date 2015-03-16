library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    Port ( clk : in  STD_LOGIC;
           inc : in  STD_LOGIC;
			  skip : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
           PCOut : out  STD_LOGIC_VECTOR (2 downto 0);
           PCIn : in  STD_LOGIC_VECTOR (2 downto 0);
           jmp : in  STD_LOGIC);
end PC;

architecture Behavioral of PC is

	signal PCVal : unsigned(2 downto 0);

begin

	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				PCVal <= "000";
			else
				if jmp = '1' then
					PCVal <= unsigned(PCIn);
				else
					if skip = '1' then
						PCVal <= PCVal + 2;
					else
						if inc = '1' then
							PCVal <= PCVal + 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	PCOut <= std_logic_vector(PCVal);

end Behavioral;

