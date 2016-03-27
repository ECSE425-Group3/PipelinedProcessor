library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HAZARD_DETECTION is

generic ( DATA_WIDTH : integer := 32
	);
port(
	IR_check	: in unsigned(DATA_WIDTH-1 downto 0);
	IR1	: in unsigned(DATA_WIDTH-1 downto 0);
	IR2	: in unsigned(DATA_WIDTH-1 downto 0);
	IR3	: in unsigned(DATA_WIDTH-1 downto 0);
	IR4	: in unsigned(DATA_WIDTH-1 downto 0);
	HAZARD	: out std_logic;
	FINAL	: out std_logic
	);

end entity;

architecture disc of HAZARD_DETECTION is

constant ADD	: unsigned(5 downto 0) := "000000";
constant SUB	: unsigned(5 downto 0) := "000001";
constant ADDI	: unsigned(5 downto 0) := "000010";
constant MULT	: unsigned(5 downto 0) := "000011";
constant DIV	: unsigned(5 downto 0) := "000100";
constant SLT	: unsigned(5 downto 0) := "000101";
constant SLTI	: unsigned(5 downto 0) := "000110";
constant ANDD	: unsigned(5 downto 0) := "000111";
constant ORR	: unsigned(5 downto 0) := "001000";
constant NORR	: unsigned(5 downto 0) := "001001";
constant XORR	: unsigned(5 downto 0) := "001010";
constant ANDI	: unsigned(5 downto 0) := "001011";
constant ORI	: unsigned(5 downto 0) := "001100";
constant XORI	: unsigned(5 downto 0) := "001101";
constant MFHI	: unsigned(5 downto 0) := "001110";
constant MFLO	: unsigned(5 downto 0) := "001111";
constant LUI	: unsigned(5 downto 0) := "010000";
constant SLLL	: unsigned(5 downto 0) := "010001";
constant SRLL	: unsigned(5 downto 0) := "010010";
constant SRAA	: unsigned(5 downto 0) := "010011";
constant LW		: unsigned(5 downto 0) := "010100";
constant LB		: unsigned(5 downto 0) := "010101";
constant SW		: unsigned(5 downto 0) := "010110";
constant SB		: unsigned(5 downto 0) := "010111";
constant BEQ	: unsigned(5 downto 0) := "011000";
constant BNE	: unsigned(5 downto 0) := "011001";
constant J		: unsigned(5 downto 0) := "011010";
constant JR		: unsigned(5 downto 0) := "011011";
constant JAL	: unsigned(5 downto 0) := "011100";


--write addresses
signal write1, write2, write3, write4 : unsigned(4 downto 0);
--read addresses
signal op1_addr, op2_addr : unsigned(4 downto 0);

--opcodes
signal IR_check_opcode : unsigned(5 downto 0);
signal IR1_opcode : unsigned(5 downto 0);
signal IR2_opcode : unsigned(5 downto 0);
signal IR3_opcode : unsigned(5 downto 0);
signal IR4_opcode : unsigned(5 downto 0);

--HAZARDS
signal op1_hazard, op2_hazard : std_logic;

begin

IR_check_opcode <= IR_check(31 downto 26);
IR1_opcode <= IR1(31 downto 26);
IR2_opcode <= IR2(31 downto 26);
IR3_opcode <= IR3(31 downto 26);
IR4_opcode <= IR4(31 downto 26);

-- get write addresses
write1 <= IR1(15 downto 11) when --store to rd
		IR1_opcode = ADD or
		IR1_opcode = SUB or
		IR1_opcode = SLT or
		IR1_opcode = ANDD or
		IR1_opcode = ORR or
		IR1_opcode = NORR or
		IR1_opcode = XORR or
		IR1_opcode = MFHI or
		IR1_opcode = MFLO or
		IR1_opcode = SLLL or
		IR1_opcode = SRLL or
		IR1_opcode = SRAA
	else IR1(20 downto 16) when --store to rt
		IR1_opcode = ADDI or
		IR1_opcode = SLTI or
		IR1_opcode = ANDI or
		IR1_opcode = ORI or
		IR1_opcode = XORI or
		IR1_opcode = LUI or
		IR1_opcode = LW or
		IR1_opcode = LB
		-- don't store anything for
		-- MULT or DIV or SW or SB or BEQ or BNE or J or JR or JAL
	else to_unsigned(0, 5);

write2 <= IR2(15 downto 11) when --store to rd
		IR2_opcode = ADD or
		IR2_opcode = SUB or
		IR2_opcode = SLT or
		IR2_opcode = ANDD or
		IR2_opcode = ORR or
		IR2_opcode = NORR or
		IR2_opcode = XORR or
		IR2_opcode = MFHI or
		IR2_opcode = MFLO or
		IR2_opcode = SLLL or
		IR2_opcode = SRLL or
		IR2_opcode = SRAA
	else IR2(20 downto 16) when --store to rt
		IR2_opcode = ADDI or
		IR2_opcode = SLTI or
		IR2_opcode = ANDI or
		IR2_opcode = ORI or
		IR2_opcode = XORI or
		IR2_opcode = LUI or
		IR2_opcode = LW or
		IR2_opcode = LB
		-- don't store anything for
		-- MULT or DIV or SW or SB or BEQ or BNE or J or JR or JAL
	else to_unsigned(0, 5);

write3 <= IR3(15 downto 11) when --store to rd
		IR3_opcode = ADD or
		IR3_opcode = SUB or
		IR3_opcode = SLT or
		IR3_opcode = ANDD or
		IR3_opcode = ORR or
		IR3_opcode = NORR or
		IR3_opcode = XORR or
		IR3_opcode = MFHI or
		IR3_opcode = MFLO or
		IR3_opcode = SLLL or
		IR3_opcode = SRLL or
		IR3_opcode = SRAA
	else IR3(20 downto 16) when --store to rt
		IR3_opcode = ADDI or
		IR3_opcode = SLTI or
		IR3_opcode = ANDI or
		IR3_opcode = ORI or
		IR3_opcode = XORI or
		IR3_opcode = LUI or
		IR3_opcode = LW or
		IR3_opcode = LB
		-- don't store anything for
		-- MULT or DIV or SW or SB or BEQ or BNE or J or JR or JAL
	else to_unsigned(0, 5);

write4 <= IR4(15 downto 11) when --store to rd
		IR4_opcode = ADD or
		IR4_opcode = SUB or
		IR4_opcode = SLT or
		IR4_opcode = ANDD or
		IR4_opcode = ORR or
		IR4_opcode = NORR or
		IR4_opcode = XORR or
		IR4_opcode = MFHI or
		IR4_opcode = MFLO or
		IR4_opcode = SLLL or
		IR4_opcode = SRLL or
		IR4_opcode = SRAA
	else IR4(20 downto 16) when --store to rt
		IR4_opcode = ADDI or
		IR4_opcode = SLTI or
		IR4_opcode = ANDI or
		IR4_opcode = ORI or
		IR4_opcode = XORI or
		IR4_opcode = LUI or
		IR4_opcode = LW or
		IR4_opcode = LB
		-- don't store anything for
		-- MULT or DIV or SW or SB or BEQ or BNE or J or JR or JAL
	else to_unsigned(0, 5);


--get read addresses
op1_addr <= to_unsigned(0, 5) when --these instructions don't read from rs
		IR_check_opcode = MFHI or
		IR_check_opcode = MFLO or
		IR_check_opcode = LUI or
		IR_check_opcode = SLLL or
		IR_check_opcode = SRAA or
		IR_check_opcode = J or
		IR_check_opcode = JAL
	else IR_check(25 downto 21);

op2_addr <= to_unsigned(0, 5) when --these instructions don't read from rt
		IR_check_opcode = ADDI or
		IR_check_opcode = SLTI or
		IR_check_opcode = ANDI or
		IR_check_opcode = ORI or
		IR_check_opcode = XORI or
		IR_check_opcode = MFHI or
		IR_check_opcode = MFLO or
		IR_check_opcode = LUI or
		IR_check_opcode = LW or
		IR_check_opcode = LB or
		IR_check_opcode = J or
		IR_check_opcode = JR or
		IR_check_opcode = JAL
	else IR_check(20 downto 16);


process(op1_addr, op2_addr, write1, write2, write3, write4)
begin
	if (op1_addr /= write1 and op1_addr /= write2 and op1_addr /= write3
		and op1_addr = write4 and op1_addr /= to_unsigned(0, 5)) or
		(op2_addr /= write1 and op2_addr /= write2 and op2_addr /= write3
		and op2_addr = write4 and op2_addr /= to_unsigned(0, 5))
	then
		FINAL <= '1';
	else
		FINAl <= '0';
	end if;
end process;

op1_hazard <= '0' when
		op1_addr = to_unsigned(0, 5) or
		(op1_addr /= write1 and
		 op1_addr /= write2 and
		 op1_addr /= write3 and
		 op1_addr /= write4)
	else '1';

op2_hazard <= '0' when
		op2_addr = to_unsigned(0, 5) or
		(op2_addr /= write1 and
		 op2_addr /= write2 and
		 op2_addr /= write3 and
		 op2_addr /= write4)
	else '1';

HAZARD <= op1_hazard or op2_hazard;

end disc;