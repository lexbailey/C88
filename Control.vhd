library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control is
    Port ( clk : in  STD_LOGIC;
           run : in  STD_LOGIC;
           step : in  STD_LOGIC;
			  stop : in  STD_LOGIC;
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

begin

	process (clk) begin
		if rising_edge(clk) then
			step_d <= step;
		end if;
	end process;
	
	step_pulse <= '1' when step_d = '0' and step = '1'
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
					
	pc_inc <= '1' when state = STEP_s and is_jump = '0'
				else '0';
				
	pc_load <= '1' when state = STEP_s and is_jump = '1'
				else '0';

end Behavioral;
