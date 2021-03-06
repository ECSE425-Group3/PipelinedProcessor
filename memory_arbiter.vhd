library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memory_arbiter_lib.all;

-- Do not modify the port map of this structure
entity memory_arbiter is
	generic (
		DATA_WIDTH : integer := 32;
		File_Address_Read : string := "Init.dat"
	);
	port(
			clk	: in STD_LOGIC;
			reset	: in STD_LOGIC;
			fetch_reset : in std_logic;
			rw_word	: in STD_LOGIC;

			--Memory port #1
			addr1	: in NATURAL;
			data1	: inout STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			re1		: in STD_LOGIC;
			we1		: in STD_LOGIC;
			busy1 : out STD_LOGIC;

			--Memory port #2
			addr2	: in NATURAL;
			data2	: inout STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			re2		: in STD_LOGIC;
			we2		: in STD_LOGIC;
			busy2 : out STD_LOGIC
	);
end memory_arbiter;

architecture behavioral of memory_arbiter is

	--Main memory signals
	--Use these internal signals to interact with the main memory
	SIGNAL mm_address       : NATURAL                                       := 0;
	SIGNAL mm_we            : STD_LOGIC                                     := '0';
	SIGNAL mm_wr_done       : STD_LOGIC                                     := '0';
	SIGNAL mm_re            : STD_LOGIC                                     := '0';
	SIGNAL mm_rd_ready      : STD_LOGIC                                     := '0';
	SIGNAL mm_data          : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)   := (others => 'Z');
	SIGNAL mm_initialize    : STD_LOGIC                                     := '0';

	type arbiter_state is (idle, start_reading, reading, start_writing, writing);
	type active_port is (none, p1, p2);

	signal state : arbiter_state;
	signal current_port : active_port;

	signal rw1 : std_logic;

begin

	--Instantiation of the main memory component (DO NOT MODIFY)
	main_memory : ENTITY work.Main_Memory
	GENERIC MAP (
		File_Address_Read	=> File_Address_Read,
		Num_Bytes_in_Word	=> NUM_BYTES_IN_WORD,
		Num_Bits_in_Byte	=> NUM_BITS_IN_BYTE,
		Read_Delay			=> 5,
		Write_Delay			=> 5
	)
	PORT MAP (
		clk			=> clk,
		address		=> mm_address,
		Word_Byte	=> rw_word,
		we			=> mm_we,
		wr_done		=> mm_wr_done,
		re			=> mm_re,
		rd_ready	=> mm_rd_ready,
		data		=> mm_data,
		initialize	=> mm_initialize,
		dump		=> '0'
	);

	rw1 <= re1 or we1;

	process (clk, reset, fetch_reset, rw1)
	begin
		if reset = '1' then
			state <= idle;
			current_port <= none;
			busy1 <= '0';
			busy2 <= '0';
		elsif fetch_reset = '1' and current_port = p2 then
			state <= idle;
			current_port <= none;
		elsif rising_edge(rw1) then
			if re1 = '1' then
				current_port <= p1;
				state <= reading;
				mm_data <= (others => 'Z');
			elsif we1 = '1' then
				current_port <= p1;
				state <= writing;
				mm_data <= data1;
			end if;
		elsif rising_edge(clk) then

			--state independent busy bit set
			if re1 = '1' or we1 = '1' then
				busy1 <= '1';
			end if;
			if re2 = '1' or we2 = '1' then
				busy2 <= '1';
			end if;

			--let memory module drive data1 bus
			data1 <= (others => 'Z');

			data2 <= (others => '0');

			case state is
				when idle =>
					--wait for user command
					if re1 = '1' then
						current_port <= p1;
						state <= reading;
						mm_data <= (others => 'Z');
					elsif we1 = '1' then
						current_port <= p1;
						state <= writing;
						mm_data <= data1;
					elsif re2 = '1' then
						current_port <= p2;
						state <= reading;
						mm_data <= (others => 'Z');
					elsif we2 = '1' then
						current_port <= p2;
						state <= writing;
						mm_data <= data2;
					end if;

				when reading =>
				--wait for data to be put on data bus
				--when ready, put data on requesting port data bus
				--then turn off busy signal and return to idle state
					if mm_rd_ready = '1' then
						if current_port = p1 then
							data1 <= mm_data;
							busy1 <= '0';
						else
							data2 <= mm_data;
							busy2 <= '0';
						end if;
						current_port <= none;
						state <= idle;
					end if;

				when writing =>
				--wait for memory to complete write
				--then turn off requesting port busy signal and return to idle state
					if mm_wr_done = '1' then
						if current_port = p1 then
							busy1 <= '0';
						else
							busy2 <= '0';
						end if;
						current_port <= none;
						state <= idle;
					end if;

				when others =>
					state <= idle;
			end case;
		end if;
	end process;

	mm_address <= addr1 when current_port = p1 else addr2;

	mm_re <= '1' when state = start_reading or state = reading else '0';
	mm_we <= '1' when state = start_writing or state = writing else '0';

end behavioral;
