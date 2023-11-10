library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_module is
	generic(
		F_CLK			: integer := 50_000_000;
		BAUDRATE		: integer := 9600;
		SAMPLING 	 : integer := 8;		
		DATABITS		: integer := 8
	);
	port(
		--Generelle 
		clk : in std_logic;
		button_n : in std_logic;
		rst_n : in std_logic;
		PARITET 		 : in std_logic;											 --'0' for paritetssjekk av
		PARITET_OP	 : in std_logic;											 --'0' for partal, '1' for oddetal 
		led_indicator: out std_logic;
		--RX-spesifikke
		rx_input  	 : in std_logic;
		recived_byte : buffer std_logic_vector(DATABITS-1 downto 0); -- Mottatt byte
		hex1, hex0   : out std_logic_vector(7 downto 0);
		--TX-spesifikke
		tx_output : out std_logic;
		tx_busy  : out std_logic
	);
end entity;

architecture rtl of tx_module is
---------------------------------------------------
-- Deklarering av signal og konstantar
---------------------------------------------------
	--SM variablar
	type DATA_SM is (IDLE, START_BIT, DATA_BIT, PARITY_BIT, STOP_BIT, PAUSE);
	signal tx_current_state : DATA_SM := IDLE;
	signal rx_current_state : DATA_SM;
	signal move_to_next  : std_logic := '0';
	--Clk signal
	signal tx_clk : std_logic := '0';
	signal rx_clk : std_logic := '0';
	--Andre signal
	signal recieved_flag : std_logic := '0';
	constant BUTTON_MSSG : std_logic_vector(DATABITS-1 downto 0) := "01110111";
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
	
	-----
	-- Funksjonen tek inn ein 4-bit lang vektor
	-- som tilsvarar eit tal mellom 0 og F (hexadesimal)
	-- og returnerar ein 8-bit lang vektor tilsvarande
	-- opplyste felt på 7-segment display
	-----
	pure function displayValue(n: std_logic_vector) return std_logic_vector is variable Ekran: std_logic_vector(7 downto 0);	
		begin
		case n is
			when "0000" => 		Ekran := "11000000"; --print 0
			when "0001" => 		Ekran := "11111001"; --print 1
			when "0010" => 		Ekran := "10100100"; --print 2
			when "0011" => 		Ekran := "10110000"; --print 3
			when "0100" => 		Ekran := "10011001"; --print 4
			when "0101" => 		Ekran := "10010010"; --print 5
			when "0110" => 		Ekran := "10000010"; --print 6
			when "0111" => 		Ekran := "11111000"; --print 7
			when "1000" => 		Ekran := "10000000"; --print 8
			when "1001" => 		Ekran := "10010000"; --print 9
			when "1010" => 		Ekran := "10001000"; --print A
			when "1011" => 		Ekran := "10000011"; --print B
			when "1100" => 		Ekran := "11000110"; --print C
			when "1101" => 		Ekran := "10100001"; --print d
			when "1110" => 		Ekran := "10000110"; --print E
			when "1111" => 		Ekran := "10001110"; --print F
			when others => Ekran := "11000000";
		end case;
		return Ekran;
	end function;
---------------------------------------------------
-- Prosessar
---------------------------------------------------	
	begin
---------------------------------------------------
-- TX
---------------------------------------------------	
	tx_clk_genereator : process(clk)
		constant TX_CLK_IN_BIT : integer := F_CLK/(BAUDRATE*2);
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

	data_send : process(tx_clk, button_n, rst_n)
		variable TX_DATA_INDEX : integer range 0 to DATABITS;
		variable TX_DATA : std_logic_vector(DATABITS-1 downto 0);

		begin
		if rising_edge(tx_clk) then
			if rst_n = '0' then
				tx_current_state <= IDLE;
			end if;
			case tx_current_state is
				when IDLE =>
					tx_output <= '1';
					if recieved_flag = '1' then
						TX_DATA := recived_byte;   	-- Tilsendt data ---> data som skal sendes
						tx_busy <= '1';       			-- TX opptatt
						tx_current_state <= START_BIT;
					-- Knappetrykk
					elsif button_n = '0' then
						TX_DATA := BUTTON_MSSG; 	-- Send testchar
						tx_busy <= '1';             -- TX opptatt
						tx_current_state <= START_BIT; 
					else
						tx_current_state <= IDLE;
					end if;
						
				when START_BIT =>
					tx_output <= '0';
					tx_current_state <= DATA_BIT;
					--tx_next_state <= DATA_BIT;

				when DATA_BIT =>
					tx_output <= TX_DATA(TX_DATA_INDEX);
					if TX_DATA_INDEX < DATABITS-1 then
						TX_DATA_INDEX := TX_DATA_INDEX + 1;
					else 
						TX_DATA_INDEX := 0;
						if PARITET = '1' then
							tx_current_state <= PARITY_BIT;
							--tx_next_state <= STOP_BIT;
						else
							tx_current_state <= STOP_BIT;
							--tx_next_state <= PAUSE;
						end if;
					end if;
				
				when PARITY_BIT =>
					if even_or_odd(TX_DATA & '0') = '1' then
						if PARITET_OP = '1' then
							tx_output <= '0';
						else
							tx_output <= '1';
						end if;
					else
						if PARITET_OP = '1' then
							tx_output <= '1';
						else
							tx_output <= '0';
						end if;
					end if;
					tx_current_state <= STOP_BIT; 
				
				when STOP_BIT => 
					tx_output <= '1';
					tx_current_state <= PAUSE;
				
				when PAUSE =>
					tx_busy <= '0';
					tx_current_state <= IDLE;
			end case;
		end if;
	end process;
---------------------------------------------------
-- RX
---------------------------------------------------
	-----
	-- Prosessen genererer rx_clk som skal ha 
	-- ein frekvens som tilsvarar 8 pulsar per
	-- bit. Dette gjerast vha. teljar
	-----
	clk_generator : process(clk)
		constant RX_CLK_IN_BIT   : integer := (F_CLK/(BAUDRATE*SAMPLING*2)); 		--Talet på klokkepulsar frå 50Hz til rx_clk(8*baudrate)
		variable rx_clk_counter : integer range 0 to RX_CLK_IN_BIT := 0;		   --Teljar brukt til å generere rx_clk
		begin
			if rising_edge(clk) then
				if(rx_clk_counter = RX_CLK_IN_BIT) then
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
		variable RX_DATA_INDEX : integer range 0 to DATABITS-1 := 0;	
		variable period_counter : integer range 0 to SAMPLING-1;			--Kontrollerar kvar vi samplar signalet
		variable rx_byte : std_logic_vector(DATABITS-1 downto 0);
		variable rx_tests 	: std_logic_vector(4 downto 0) := (others => '0');	
		begin
		if rising_edge(rx_clk)then
			if rst_n = '0' then
				rx_current_state <= IDLE;
				rx_byte := (others => '0');
				recived_byte <= (others => '0');
			end if;
			case rx_current_state is
				--State: IDLE, program waiting for startbit
				when IDLE =>
					RX_DATA_INDEX := 0;
					period_counter := 0;
					rx_byte := (others => '0');
					if rx_input = '0' then
						rx_current_state <= START_BIT;
					else
						rx_current_state <= IDLE;
					end if;
				--State: START_BIT, program double checks startbit
				when START_BIT =>
					if period_counter = SAMPLING-1 then
						if move_to_next = '1' then
							rx_current_state <= DATA_BIT;
							period_counter := 2; 		--Setter til 2 for å gjøre opp for timing-delays i denne casen
						else
							rx_current_state <= IDLE;
						end if;
					elsif period_counter = SAMPLING/2 then
						if rx_input = '0' then
							move_to_next <= '1';
							period_counter := period_counter + 1;
							rx_current_state <= START_BIT;
						else
							rx_current_state <= IDLE;
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
							rx_tests(period_counter-2) := rx_input;
							--test_sampling <= '1';
						--else
							--test_sampling <= '0'; 
						end if;
						period_counter := period_counter + 1;
						rx_current_state <= DATA_BIT;
					else
						period_counter := 0;
						rx_byte(RX_DATA_INDEX) := majority_decision(rx_tests);
						rx_tests := "00000";
						if RX_DATA_INDEX < DATABITS-1 then
							RX_DATA_INDEX := RX_DATA_INDEX + 1;
							rx_current_state <= DATA_BIT;
						else 
							RX_DATA_INDEX := 0;
							if PARITET = '1' then
									rx_current_state <= PARITY_BIT;
							else
								rx_current_state <= STOP_BIT;
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
							rx_current_state <= STOP_BIT;
						else
							 rx_current_state <= IDLE;
						end if;
					end if;
				--State: STOP_BIT, program checks if stop-condition is recieved
				when STOP_BIT =>
					if period_counter < SAMPLING/2 then
						period_counter := period_counter + 1;
						rx_current_state <= STOP_BIT;
					else
						period_counter := 0;
						
						if rx_input = '1' then
							recieved_flag <= '1';
							recived_byte <= rx_byte;
							period_counter := 0;
							rx_current_state <= PAUSE;
						else
							rx_current_state <= IDLE;
						end if;
						
					end if;
				--State: PAUSE, program forces a 1-bit pause
				when PAUSE =>
					if period_counter < SAMPLING-1 then
						period_counter := period_counter + 1;
					else
						period_counter := 0;
						recieved_flag <= '0';
						rx_current_state <= IDLE;
					end if;
			end case;
		end if;
	end process;
	
	-----
	-- Processen handterar LED-lyset som skal være
	-- på i ein kort periode etter mottatt RX-melding
	-----
	ctrl : process(clk, recieved_flag)
		constant led_rate : integer := F_CLK*5/100;
		variable led_counter : integer range 0 to led_rate;
		variable led_on : std_logic := '0';
		
		begin
		if rising_edge(clk) then
			--HEX kontroll
			hex1 <=  displayValue(recived_byte(7 downto 4));
			hex0 <=  displayValue(recived_byte(3 downto 0));
			--RX/TX-kontroll
			if recieved_flag = '1' then
				led_on := '1';
			end if;
			
			--LED indikator teljar
			if led_on = '1' then
				if led_counter < led_rate then
					led_counter := led_counter + 1;
					led_indicator <= '1';
				else
					led_counter := 0;
					led_indicator <= '0';
					led_on := '0';
				end if;
			end if;
		end if;
	end process;
end architecture;
