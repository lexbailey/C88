library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity InstructionDecoder is
    Port ( opcode : in  STD_LOGIC_VECTOR (7 downto 0);
           addr : out  STD_LOGIC_VECTOR (2 downto 0);
           ALU_op : out  STD_LOGIC_VECTOR (3 downto 0);
			  COMP_op : out  STD_LOGIC_VECTOR (1 downto 0);
           reg_wen : out  STD_LOGIC;
           ram_wen : out  STD_LOGIC;
			  stop : out  STD_LOGIC;
			  is_jump : out  STD_LOGIC;
			  jump_type : out  STD_LOGIC;
			  reg_input_select: out STD_LOGIC;
			  is_test : OUT STD_LOGIC;
			  is_iow : OUT STD_LOGIC;
			  is_io_in : OUT STD_LOGIC;
			  io_reg_in_sel: OUT STD_LOGIC);
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is

begin

	--easy bit first, the address is allways the last three bits
	addr <= opcode(2 downto 0);
	
	--also easy, ALU op. We can se this up even when not used.
	ALU_op <= opcode(6 downto 3);
	
	--Arithmetic operations all have opcodes starting with a 1
	--All aritmetic operations require reg_wen high. it should
	--also be high for load and swap.
	--Load and swap are encoded as 00000 and 00001, so test
	--first four bits for zero to detect load or swap
	--Also, IO read or swap requires this to be high, 01101 or 01110
	reg_wen <= '1' when ((opcode(7) = '1') or (opcode(7 downto 4) = "0000")) or ((opcode(7 downto 5) = "011") and (opcode(4)='1' xor opcode(3)='1'))
			else '0';
			
	--select ram input when doing load or swap
	reg_input_select <= '1' when opcode(7 downto 4) = "0000"
			else '0';
	
	--The ram should be writable for a store or swap.
	--store is 00010 and swap is 00001. so test for three 0s
	--and then an xor on the last two.
	ram_wen <= '1' when (opcode(7 downto 5) = "000") and ((opcode(4) xor opcode(3)) = '1')
			else '0';

	--detect stop instruction
	stop <= '1' when opcode(7 downto 3) = "00011"
			else '0';
			
	--detect jumps (starts 010)
	is_jump <= '1' when opcode(7 downto 4) = "0100"
			else '0';
			
	jump_type <= opcode(3);
	
	is_test <= '1' when opcode (7 downto 5) = "001"
			else '0';
			
	COMP_op <= opcode(4 downto 3);

--01101 IOR	IO read, read input to register

	--make IO output register writable for IOW (IO write), IOS (IO swap) and IOC (IO clear)
	is_iow <= '1' when (opcode(7 downto 3) = "01100") or (opcode(7 downto 3) = "01110") or (opcode(7 downto 3) = "01111")
			else '0';
			
	io_reg_in_sel <= opcode(3);
	
	is_io_in <= '1' when (opcode (7 downto 3) = "01110") or (opcode (7 downto 3) = "01101")
			else '0';

end Behavioral;

