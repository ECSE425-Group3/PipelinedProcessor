library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEMORY is

generic ( DATA_WIDTH : integer := 32
	);
port(	clk	: in std_logic;
	branch_taken	: in std_logic;
	alu_result_in	: in unsigned(DATA_WIDTH-1 downto 0);
	op2_in	: in unsigned(DATA_WIDTH-1 downto 0);
	IR_in	: in unsigned(DATA_WIDTH-1 downto 0);
	memory	: out unsigned(DATA_WIDTH-1 downto 0);
	branch_taken_out : out std_logic := '0';
	alu_result_out	: out unsigned(DATA_WIDTH-1 downto 0);
	IR_out	: out unsigned(DATA_WIDTH-1 downto 0);
	-- memory access
	ID_addr	: out NATURAL := 0;
	ID_data	: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	ID_re	: out STD_LOGIC;
	ID_we	: out STD_LOGIC;
	ID_busy	: in STD_LOGIC
	);

end entity;

architecture disc of MEMORY is

constant LOAD_WORD : unsigned(5 downto 0) := "010100";
constant LOAD_BYTE : unsigned(5 downto 0) := "010101";

constant STORE_WORD : unsigned(5 downto 0) := "010110";
constant STORE_BYTE : unsigned(5 downto 0) := "010111";



signal op : unsigned(5 downto 0);
signal reading, writing : std_logic := '0';
begin

op <= IR_in(DATA_WIDTH-1 downto DATA_WIDTH-6);
ID_re <= reading;
ID_we <= writing;

update_values : process(clk)
begin
	if (rising_edge(clk)) then
		if ((ID_busy = '0' and reading = '1')) then
			reading <= '0';
		elsif (op = LOAD_WORD or op = LOAD_BYTE) then
			reading <= '1';
			writing <= '0';
			ID_addr <= to_integer(alu_result_in);
		elsif (op = STORE_WORD or op = STORE_BYTE) then
			reading <= '0';
			writing <= '1';
		end if;
	end if;
end process;

end disc;