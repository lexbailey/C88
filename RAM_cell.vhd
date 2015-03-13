library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--This is a single RAM cell (one 8 bit register with write enable)

entity RAM_cell is
    Port ( clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0);
           wen : in  STD_LOGIC);
end RAM_cell;

architecture Behavioral of RAM_cell is
	signal data: std_logic_vector (7 downto 0);
begin

	--bunch of flipflops

	process (clk) begin
		--on a rising clock edge
		if rising_edge(clk) then
			--if write is enabled
			if wen = '1' then
				--store new data
				data <= data_in;
			end if;
		end if;
	end process;

	data_out <= data;

end Behavioral;

