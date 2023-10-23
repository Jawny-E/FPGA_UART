library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_module is
	generic(
	F_CLK 		 : integer := 50_000_000; 	--50mHz (Hz)
	BAUDRATE 	 : integer := 9600; 	 		--Gitt baudrate(bit/s)
	SAMPLING 	 : integer := 8;				--Sampling per periode(per bit)
	DATABITS 		 : integer := 8				--Bit i ein pakke
	--PARITET 		 : std_logic := '0';			--'0' for paritetssjekk av
	--PARITET_OP	 : std_logic := '0'			--'0' for partal, '1' for oddetal 
	);
	
	port(
		clk 			 : in std_logic;							  		  -- Intern klokke	
		rx_input  	 : in std_logic;							  		  -- Seriellt signal
		recived_flag : out std_logic;							  		  -- Flagg for mottat byte
		recived_byte : out std_logic_vector(DATABITS-1 downto 0) -- Motatt byte
	);
end entity;



architecture rtl of rx_module is 
	--State machine kontroller
	type RX_SM is (IDLE, START_BIT, DATA_BIT, STOP_BIT, PAUSE);
	signal current_state : RX_SM := IDLE;
	--Klokkegenerering
	constant clk_in_bit : integer := (F_CLK/BAUDRATE/SAMPLING-1);
	signal rx_clk_counter : integer range 0 to CLK_IN_BIT := 0;
	signal rx_clk : std_logic := '0';
	signal period_counter : integer range 0 to SAMPLING-1;
	--Dataavlesning
	signal DATA_INDEX : integer range 0 to DATABITS-1 := 0;
	signal rx_byte		: std_logic_vector(DATABITS-1 downto 0) := (others => '0');
	
	
	begin
	
	-- Prosessen genererer klokkesignal som har frekvens tilsvarande samplingsrate
	clk_generator : process(clk)
	begin
		if rising_edge(clk) then
			if(rx_clk_counter = clk_in_bit) then
				rx_clk <= not rx_clk;
				rx_clk_counter <= 0;
			else
				rx_clk_counter <= rx_clk_counter + 1;
			end if;
		end if;
	end process;
	
	--Prosessen skal lese av innkommande data
	data_read : process(rx_clk)
	begin
		if rising_edge(rx_clk)then
			case current_state is
				when IDLE =>
					-- Setter telleverdier lik 0
					DATA_INDEX <= 0;
					period_counter <= 0;
					rx_byte <= (others => '0');
					-- Sjekk om startbit er mottatt
					if rx_input = '0' then
						current_state <= START_BIT;
					else
						current_state <= IDLE;
						
					end if;
					
				when START_BIT =>
					-- Dobbeltsjekk startbit 
					if period_counter = SAMPLING/2 then
						if rx_input = '0' then
							current_state <= DATA_BIT;
							period_counter <= 0;
						else
							current_state <= IDLE;
						end if;
					else
						period_counter <= period_counter + 1;
					end if;
					
				when DATA_BIT =>
					-- Les av bit med korrekt timing og index
					-- Inkrementer DATA_INDEX
					-- Legg til bit i signalet rx_byte
					if period_counter < SAMPLING-1 then
						period_counter <= period_counter + 1;
						current_state <= DATA_BIT;
					else
						period_counter <= 0;
						rx_byte(DATA_INDEX) <= rx_input;
						
						if DATA_INDEX < DATABITS-1 then
							DATA_INDEX <= DATA_INDEX + 1;
							current_state <= DATA_BIT;
						else 
							DATA_INDEX <= 0;
							current_state <= STOP_BIT;
						end if;
					end if;
					
				when STOP_BIT =>
					-- Sjekk at stoppbit er mottatt
					recived_byte <= rx_byte;
					
					if period_counter < SAMPLING-1 then
						period_counter <= period_counter + 1;
						current_state <= STOP_BIT;
					else
						recived_flag <= '1';
						period_counter <= 0;
						current_state <= PAUSE;
					end if;
					
				when PAUSE =>
					if period_counter < SAMPLING-1 then
						period_counter <= period_counter + 1;
					else
						period_counter <= 0;
						current_state <= IDLE;
						recived_flag <= '0';
					end if;
			end case;
		end if;
	end process;

end architecture;
