----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:30:37 03/13/2015 
-- Design Name: 
-- Module Name:    register - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_8 is
    Port ( clk : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0);
           wen : in  STD_LOGIC;
           rst : in  STD_LOGIC);
end register_8;

architecture Behavioral of register_8 is

	signal data: std_logic_vector (7 downto 0);

begin

	process (clk) begin
		--on a rising clock edge
		if rising_edge(clk) then
			if rst = '1' then
				data <= "00000000";
			else
				--if write is enabled
				if wen = '1' then
					--store new data
					data <= data_in;
				end if;
			end if;	
		end if;
	end process;

	data_out <= data;

end Behavioral;

