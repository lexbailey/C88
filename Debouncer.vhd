----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:34:13 06/02/2015 
-- Design Name: 
-- Module Name:    Debouncer - Behavioral 
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
use IEEE.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Debouncer is
    generic (	CLK_DIV : natural := 32;
					CHECK_BITS : natural := 32
				);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           sig : in  STD_LOGIC;
           deb_sig : out  STD_LOGIC);
end Debouncer;

architecture Behavioral of Debouncer is
	signal check : std_logic_vector(CHECK_BITS-1 downto 0);
	signal divClk: std_logic;
	signal count: std_logic_vector(integer(ceil(log2(real(CLK_DIV)))) downto 0);
	signal checkhigh : std_logic_vector(CHECK_BITS-1 downto 1);
	signal checklow: std_logic;
begin

	divClk <= '1' when count = (count'HIGH downto 0 => '0') else '0';
	
	checkhigh <= check(CHECK_BITS-1 downto 1);
	
	checklow <= check(0);

	process(clk) begin
		if (rising_edge(clk)) then
		
			if rst = '1' then
				count <= (others => '0');
				check(check'HIGH) <= '0';
			else
		
				if count = (count'HIGH downto 0 => '1') then
					count <= (others => '0');
				else
					count <= std_logic_vector(unsigned(count) +1);
				end if;
				
				if divClk = '1' then
					check(check'HIGH) <= sig;
				end if;
				if (checklow = '0') and (checkhigh = (checkhigh'HIGH downto checkhigh'LOW => '1')) then
					deb_sig <= '1';
				else 
					deb_sig <= '0';
				end if;
			end if;
		end if;
	end process;
	
	shifter: for I in 0 to (CHECK_BITS-2) generate
		process (clk) begin
			if (rising_edge(clk)) then
				if rst = '1' then
					check(i) <= '0';
				else
					if divClk = '1' then
						check(i) <= check(i+1);
					end if;
				end if;
			end if;
		end process;
	end generate;
	
	

end Behavioral;

