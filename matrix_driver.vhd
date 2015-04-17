library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_package.all;

entity matrix_driver is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           MOSI : out  STD_LOGIC;
			  MISO : in  STD_LOGIC;
           SS : out  STD_LOGIC;
           SCK : buffer  STD_LOGIC;
			  Matrix_data : in cell_select_array);
end matrix_driver;

architecture Behavioral of matrix_driver is
	COMPONENT spi_master
	GENERIC(
    slaves  : INTEGER;  --number of spi slaves
    d_width : INTEGER); --data bus width
	PORT(
		clock : IN std_logic;
		reset_n : IN std_logic;
		enable : IN std_logic;
		cpol : IN std_logic;
		cpha : IN std_logic;
		cont : IN std_logic;
		clk_div : IN integer;
		addr : IN integer;
		tx_data : IN std_logic_vector(d_width-1 downto 0);
		miso : IN std_logic;          
		sclk : buffer std_logic;
		ss_n : buffer std_logic_vector(slaves-1 downto 0);
		mosi : OUT std_logic;
		busy : OUT std_logic;
		rx_data : OUT std_logic_vector(d_width-1 downto 0)
		);
	END COMPONENT;
	
	signal output : std_logic_vector(15 downto 0);
	signal temp_output : std_logic_vector(15 downto 0);	
	signal input : std_logic_vector(15 downto 0);
	
	signal address : integer;
	signal clk_div : integer;
	
	signal cpol : std_logic;
	signal cpha : std_logic;
	
	signal busy : std_logic;
	
	signal continuous : std_logic;
	
	signal enable : std_logic;
	
	type cell_select_array_plus_one is array (0 to 8) of std_logic_vector(7 downto 0);
	--signal LED_Data: cell_select_array;
	signal LED_Data: cell_select_array_plus_one;
	
	type setup_array is array (0 to 7) of std_logic_vector(7 downto 0);
	--Values 0, 1, 2, 3 and 6 are used, values 4, 5 and 7 are dummy values
	constant max_config: setup_array := ("00000000","11111111","11111111","11111111","00000000","00000000","00000000","00000000");
	
	signal hard_addr: std_logic_vector(3 downto 0);
	signal conf_addr: std_logic_vector(2 downto 0);
	signal line_addr: std_logic_vector(3 downto 0);
	
	signal is_setup: std_logic;
	
	signal ssvec : std_logic_vector (0 downto 0);
	
	signal reset_n: std_logic;
begin

	LED_Data(0) <= Matrix_data(0);
	LED_Data(1) <= Matrix_data(1);
	LED_Data(2) <= Matrix_data(2);
	LED_Data(3) <= Matrix_data(3);
	LED_Data(4) <= Matrix_data(4);
	LED_Data(5) <= Matrix_data(5);
	LED_Data(6) <= Matrix_data(6);
	LED_Data(7) <= Matrix_data(7);
	LED_Data(8) <= "00000000";

	reset_n <= not rst;

	ss <= ssvec(0);

	address <= 0;
	clk_div <= 1;
	
	cpol <= '0';
	cpha <= '0';

	continuous <= '0';

	Inst_spi_master: spi_master 
	GENERIC MAP(
	  slaves => 1,
     d_width => 16
	)
	PORT MAP(
		clock => clk,
		reset_n => reset_n,
		enable => enable,
		cpol => cpol,
		cpha => cpha,
		cont => continuous,
		clk_div => clk_div,
		addr => address,
		tx_data => output,
		miso => miso,
		sclk => sck,
		ss_n => ssvec,
		mosi => mosi,
		busy => busy,
		rx_data => input
	);
	
	temp_output(15 downto 12) <= "0000";
	temp_output(11 downto 8) <= hard_addr;
	temp_output(7 downto 0) <= max_config(to_integer(unsigned(conf_addr))) when is_setup = '1'
							else LED_Data(to_integer(unsigned(line_addr)));
							
	hard_addr <= std_logic_vector(resize(unsigned(conf_addr),4)+9) when is_setup = '1'
							else std_logic_vector(unsigned(line_addr)+1);
							
	
	process (clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				conf_addr <= "000";
				line_addr <= "0000";
				is_setup <= '1';
				enable <= '0';
			else
				if busy = '0' and enable = '0' then
					if is_setup = '1' then
						conf_addr <= std_logic_vector(unsigned(conf_addr) + 1);
					else
						line_addr <= std_logic_vector(unsigned(line_addr) + 1);
					end if;
					
					output <= temp_output;
					
					enable <= '1';
				else
					enable <= '0';
				end if;
				if is_setup = '1' then
					if conf_addr = "111" then
						is_setup <= '0';
						line_addr <= "0000";
					end if;
				else
					if line_addr = "1000" then
						is_setup <= '1';
						conf_addr <= "000";
					end if;
				end if;
			end if;
		end if;
	end process;
	
--	process (clk) begin
--		if rising_edge(clk) then
--			if rst = '1' then
--				LED_Data(0) <= "00000000";
--				LED_Data(1) <= "00000000";
--				LED_Data(2) <= "00000000";
--				LED_Data(3) <= "00000000";
--				LED_Data(4) <= "00000000";
--				LED_Data(5) <= "00000000";
--				LED_Data(6) <= "00000000";
--				LED_Data(7) <= "00000000";
--			else
--		
--				LED_Data(0) <= std_logic_vector(unsigned(LED_Data(0))+1);
--				if LED_Data(0) = "11111111" then LED_Data(1) <= std_logic_vector(unsigned(LED_Data(1))+1); end if;
--				if LED_Data(1) = "11111111" then LED_Data(2) <= std_logic_vector(unsigned(LED_Data(2))+1); end if;
--				if LED_Data(2) = "11111111" then LED_Data(3) <= std_logic_vector(unsigned(LED_Data(3))+1); end if;
--				if LED_Data(3) = "11111111" then LED_Data(4) <= std_logic_vector(unsigned(LED_Data(4))+1); end if;
--				if LED_Data(4) = "11111111" then LED_Data(5) <= std_logic_vector(unsigned(LED_Data(5))+1); end if;
--				if LED_Data(5) = "11111111" then LED_Data(6) <= std_logic_vector(unsigned(LED_Data(6))+1); end if;
--				if LED_Data(6) = "11111111" then LED_Data(7) <= std_logic_vector(unsigned(LED_Data(7))+1); end if;
--			end if;
--		end if;
--	end process;

end Behavioral;

