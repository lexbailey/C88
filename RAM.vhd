library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_package.all;

--This is the entire RAM. A set of eight instances of the 8 bit cells


entity RAM is
	
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (2 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0);
			  display_out : out cell_select_array;
           wen : in  STD_LOGIC);
end RAM;

architecture Behavioral of RAM is

	COMPONENT RAM_cell
	PORT(
		clk : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		wen : IN std_logic;          
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	--For address decoding
	COMPONENT decode_3_to_8
	PORT(
		input : IN std_logic_vector(2 downto 0);          
		output : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	signal wen_sel: std_logic_vector(7 downto 0);
	signal addr_sel: std_logic_vector(7 downto 0);

	--type cell_select_array is array (0 to 7) of std_logic_vector(7 downto 0);
	signal cell_data_select: cell_select_array;
begin

	cell_array: for i in 0 to 7 generate
		Inst_RAM_cell: RAM_cell PORT MAP(
			clk => clk,
			data_in => data_in,
			data_out => cell_data_select(i),
			wen => wen_sel(i)
		);
	end generate;
	
	Inst_decode_3_to_8: decode_3_to_8 PORT MAP(
		input => addr,
		output => addr_sel
	);
	
	wen_selector: for i in 0 to 7 generate
		wen_sel(i) <= addr_sel(i) and wen;
	end generate;
	
	data_out <= cell_data_select(to_integer(unsigned(addr)));

	display_out <= cell_data_select;

end Behavioral;

