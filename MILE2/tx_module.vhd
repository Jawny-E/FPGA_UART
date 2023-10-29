library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_module is
	generic(
		F_CLK			: integer := 50_000_000;
		BAUDRATE		: integer := 9600;
		DATABITS		: integer := 8
	);
	port(
		clk : in std_logic;
		button_n : in std_logic;
		tx_output : out std_logic;
		test_clk : out std_logic
	);
end entity;

architecture rtl of tx_module is
	type DATA_SM is (IDLE, START_BIT, DATA_BIT, PARITY_BIT, STOP_BIT, PAUSE);
	signal tx_current_state : DATA_SM := IDLE;
	signal tx_next_state : DATA_SM := IDLE;
	
	constant BUTTON_MSSG : std_logic_vector(DATABITS-1 downto 0) := "00110011";
	constant TX_CLK_IN_BIT : integer := F_CLK/(BAUDRATE*2);
	
	signal tx_clk : std_logic := '0';
	
	begin
	tx_clk_genereator : process(clk)
		variable tx_clk_counter : integer range 0 to TX_CLK_IN_BIT;
		begin
		if rising_edge(clk) then
			if (tx_clk_counter = TX_CLK_IN_BIT) then
				tx_clk <= not tx_clk;
				tx_clk_counter := 0;
			else
				tx_clk_counter := tx_clk_counter + 1;
			end if;
		end if;
	end process;
	
	data_send : process(tx_clk, button_n)
		variable TX_DATA_INDEX : integer range 0 to DATABITS;
		variable TX_DATA : std_logic_vector(DATABITS-1 downto 0);
		
		begin
		if rising_edge(tx_clk) then
			tx_current_state <= tx_next_state;
			case tx_current_state is
				
				when IDLE =>
					TX_DATA_INDEX := 0;
					if (button_n = '0') then
						TX_DATA := BUTTON_MSSG;
						tx_next_state <= START_BIT;
					--elsif recivedflag = '1'
					-- TX_DATA := recived_byte
					--tx_current_state <= START_BIT
					else
						tx_next_state <= IDLE;
					end if;
				
					
				when START_BIT =>
					test_clk <= '0';
					tx_output <= '0';
					tx_next_state <= DATA_BIT;
				
				when DATA_BIT =>
					test_clk <= '1';
					tx_output <= TX_DATA(TX_DATA_INDEX);
					if TX_DATA_INDEX < DATABITS-1 then
						TX_DATA_INDEX := TX_DATA_INDEX + 1;
					else 
						--PARITET HER
						tx_next_state <= STOP_BIT;
					end if;
				
				when STOP_BIT => 
					test_clk <= '0';
					tx_output <= '1';
					tx_next_state <= PAUSE;
				
				when PARITY_BIT =>
					test_clk <= '0';
					tx_next_state <= STOP_BIT;
				
				when PAUSE =>
					test_clk <= '0';
					tx_next_state <= IDLE;
			end case;
		end if;
	end process;
end architecture;
