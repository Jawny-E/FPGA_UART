library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_module is
	generic(
	F_CLK 		 : integer := 50_000_000; 	--50mHz (Hz)
	BAUDRATE 	 : integer := 9600; 	 		--Gitt baudrate(bit/s)
	SAMPLING 	 : integer := 8;				--Sampling per periode(per bit)
	DATABITS 		 : integer := 8				--Bit i ein pakke
	);
	
	port(
		clk 			 : in std_logic;							  		 		 -- Intern klokke	
		rx_input  	 : in std_logic;							  		  		 -- Seriellt signal
		PARITET 		 : in std_logic;											 --'0' for paritetssjekk av
		PARITET_OP	 : in std_logic;											 --'0' for partal, '1' for oddetal 
		recived_byte : buffer std_logic_vector(DATABITS-1 downto 0) -- Mottatt byte
	);
end entity;



architecture rtl of rx_module is 
---------------------------------------------------
-- Deklarering av signal og konstantar
---------------------------------------------------

	--State machine kontroller
	type RX_SM is (IDLE, START_BIT, DATA_BIT, PARITY_BIT, STOP_BIT, PAUSE);	--Ulike states for dataavlesning
	signal current_state : RX_SM;															--Variabel som held noværande state
	signal move_to_next  : std_logic := '0';											--Brukt til å dobbeltsjekke startbit
	--Klokkegenerering
	constant clk_in_bit   : integer := (F_CLK/(BAUDRATE*SAMPLING*2)); 		--Talet på klokkepulsar frå 50Hz til rx_clk(8*baudrate)
	signal rx_clk         : std_logic := '0';											--Signalet rx_clk
	--Dataavlesning
	signal DATA_INDEX : integer range 0 to DATABITS-1 := 0;								--Kontrollerar kva databit som blir lest
	signal rx_byte		: std_logic_vector(DATABITS-1 downto 0) := (others => '0'); --Mellombels lagring for innkommande data
	signal rx_tests 	: std_logic_vector(4 downto 0) := (others => '0');				--Mellombels lagring av signalsampler
	signal recieved_flag : std_logic := '0';
	
---------------------------------------------------
-- Funksjonar
---------------------------------------------------	
	
	-----
	--Funksjonen sjekker om ein vektor med lengde
	--databits + 1 har odde eller jamnt tal 1arar
	--dette er brukt i paritetssjekk
	-----
	pure function even_or_odd(input_vector : std_logic_vector(DATABITS downto 0)) return std_logic is
	variable count_1s : integer range 0 to 9 := 0;
	begin
	for i in input_vector'range loop
			if input_vector(i) = '0' then
				count_1s := count_1s;
			else
				count_1s := count_1s + 1;
			end if;
	end loop;
		
	if (count_1s mod 2) = 0 then
	-- it's even
		return '0';
	else
	-- it's odd
		return '1';
	end if;
	end function;
	
	------
	-- Funksjonen looper gjennom innkommande vektor
	-- og teljar opp talet på 0arar og 1arar
	-- deretter samanliknast dei, og majoritet blir
	-- returnert ('0' eller '1')
	------
	function majority_decision(input_vector : std_logic_vector(4 downto 0)) return std_logic is
		variable count_0 : integer range 0 to 5 := 0;
		variable count_1 : integer range 0 to 5 := 0;
		begin
		for i in input_vector'range loop
			if input_vector(i) = '0' then
				count_0 := count_0 + 1;
			else
				count_1 := count_1 + 1;
			end if;
		end loop;
		
		if count_0 > count_1 then
			return '0';
		else
			return '1';
		end if;
	end function;
---------------------------------------------------
-- Prosessar
---------------------------------------------------		
	begin
	
	-----
	-- Prosessen genererer rx_clk som skal ha 
	-- ein frekvens som tilsvarar 8 pulsar per
	-- bit. Dette gjerast vha. teljar
	-----
	clk_generator : process(clk)
	variable rx_clk_counter : integer range 0 to CLK_IN_BIT := 0;		   --Teljar brukt til å generere rx_clk
	begin
		if rising_edge(clk) then
			if(rx_clk_counter = clk_in_bit) then
				rx_clk <= not rx_clk;
				rx_clk_counter := 0;
			else
				rx_clk_counter := rx_clk_counter + 1;
			end if;
			--test_clk <= rx_clk;
		end if;
	end process;
	
	-----
	-- Prosessen handterar avlesning av seriell
	-- data, dette gjerast vha. ein statemachine
	-- Den er avhengig av signalet rx_clk som bestemmer
	-- timing for systemet
	-----
	data_read : process(rx_clk)
	variable period_counter : integer range 0 to SAMPLING-1;			--Kontrollerar kvar vi samplar signalet
		begin
		if rising_edge(rx_clk)then
			case current_state is
				--State: IDLE, program waiting for startbit
				when IDLE =>
					DATA_INDEX <= 0;
					period_counter := 0;
					rx_byte <= (others => '0');
					if rx_input = '0' then
						current_state <= START_BIT;
					else
						current_state <= IDLE;
					end if;
				--State: START_BIT, program double checks startbit
				when START_BIT =>
					if period_counter = SAMPLING-1 then
						if move_to_next = '1' then
							current_state <= DATA_BIT;
							period_counter := 2; 		--Setter til 2 for å gjøre opp for timing-delays i denne casen
						else
							current_state <= IDLE;
						end if;
					elsif period_counter = SAMPLING/2 then
						if rx_input = '0' then
							move_to_next <= '1';
							period_counter := period_counter + 1;
							current_state <= START_BIT;
						else
							current_state <= IDLE;
							period_counter := 0;
						end if;
					else
						period_counter := period_counter + 1;
					end if;
				--State: DATA_BIT, program is reading input at set intervals
				when DATA_BIT =>
					--test_rx_tests <= rx_tests;
					if period_counter < SAMPLING-1 then
						if (period_counter < 7) and (period_counter > 1) then
							rx_tests(period_counter-2) <= rx_input;
							--test_sampling <= '1';
						--else
							--test_sampling <= '0'; 
						end if;
						period_counter := period_counter + 1;
						current_state <= DATA_BIT;
					else
						period_counter := 0;
						rx_byte(DATA_INDEX) <= majority_decision(rx_tests);
						rx_tests <= "00000";
						if DATA_INDEX < DATABITS-1 then
							DATA_INDEX <= DATA_INDEX + 1;
							current_state <= DATA_BIT;
						else 
							DATA_INDEX <= 0;
							if PARITET = '1' then
									current_state <= PARITY_BIT;
							else
								current_state <= STOP_BIT;
							end if;
						end if;
					end if;
				--State: PARITY_BIT, program checks additional bit and analyses message validity
				when PARITY_BIT =>
					if period_counter < SAMPLING-1 then
						period_counter := period_counter + 1;
					else
						period_counter := 0;
						if even_or_odd(rx_byte & rx_input) = PARITET_OP then
							current_state <= STOP_BIT;
						else
							 current_state <= IDLE;
						end if;
					end if;
				--State: STOP_BIT, program checks if stop-condition is recieved
				when STOP_BIT =>
					if period_counter < SAMPLING/2 then
						period_counter := period_counter + 1;
						current_state <= STOP_BIT;
					else
						period_counter := 0;
						
						if rx_input = '1' then
							recieved_flag <= '1';
							recived_byte <= rx_byte;
							period_counter := 0;
							current_state <= PAUSE;
						else
							current_state <= IDLE;
						end if;
						
					end if;
				--State: PAUSE, program forces a 1-bit pause
				when PAUSE =>
					if period_counter < SAMPLING-1 then
						period_counter := period_counter + 1;
					else
						period_counter := 0;
						recieved_flag <= '0';
						current_state <= IDLE;
					end if;
			end case;
		end if;
	end process;
end architecture;
