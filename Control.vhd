library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control is
    Port ( clk : in  STD_LOGIC;
           run : in  STD_LOGIC;
           step : in  STD_LOGIC;
			  stop : in  STD_LOGIC;
			  skip : in  STD_LOGIC;
			  is_jump : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ram_addr_sel : out  STD_LOGIC;
           is_exec : out  STD_LOGIC;
           instr_reg_wen : out  STD_LOGIC;
           pc_inc : out  STD_LOGIC;
           pc_load : out  STD_LOGIC);
end Control;

architecture Behavioral of Control is

	type machine_state is (READ_s, EXECUTE_s, STEP_s, PAUSE_s);
	signal state: machine_state;
	signal next_state: machine_state;
	signal step_d: std_logic;
	signal step_pulse: std_logic;

	signal debounceshift: std_logic_vector(15 downto 0);

	signal debouncecount: unsigned(17 downto 0);
	
	signal step_deb_enable: std_logic;
	
	signal last_bit: std_logic;

begin

	step_deb_enable <= '1' when debouncecount = "111111111111111111"
			else '0';
			
	debounceshift(0) <= step;

	process (clk) begin
		if rising_edge(clk) then
			last_bit <= debounceshift(15);
			debouncecount <= debouncecount+1;
			if step_deb_enable = '1' then
				debounceshift(15 downto 1) <= debounceshift(14 downto 0);
			end if;
		end if;
	end process;
	
	
	step_pulse <= '1' when debounceshift = "1111111111111111" and last_bit = '0'
			else '0';

	process (clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				state <= PAUSE_s;
			else
				state <= next_state;
			end if;
		end if;
	end process;
	
	process (state, stop, run, step_pulse) begin
		case state is
			when READ_s =>
				next_state <= EXECUTE_s;
			when EXECUTE_s =>
				if stop = '0' then
					next_state <= STEP_s;
				else 
					next_state <= EXECUTE_s;
				end if;
			when STEP_s =>
				if run = '0' then
					next_state <= PAUSE_s;
				else 
					next_state <= READ_s;
				end if;
			when PAUSE_s =>
				if (run = '1' or step_pulse = '1') then
					next_state <= READ_s;
				else
					next_state <= state;
				end if;
		end case;
	end process;
	
	ram_addr_sel <= '0' when state = READ_s
					else '1' when state = EXECUTE_s
					else '0';
					
	instr_reg_wen <= '1' when state = READ_s
					else '0';
					
	is_exec <= '1' when state = EXECUTE_s
					else '0';
					
	pc_inc <= '1' when (state = STEP_s and is_jump = '0') or (state = EXECUTE_s and skip = '1')
				else '0';
				
	pc_load <= '1' when state = STEP_s and is_jump = '1' and skip = '0'
				else '0';

end Behavioral;

