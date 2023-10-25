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
		recived_byte : buffer std_logic_vector(DATABITS-1 downto 0); -- Motatt byte
		hex1, hex0 : out std_logic_vector(7 downto 0) -- Output: Signal til eit 7-segment display
		--test_clk : out std_logic;	
		--test_sampling : out std_logic;
		--test_rx_tests : out std_logic_vector(4 downto 0)
	);
end entity;



architecture rtl of rx_module is 
	--State machine kontroller
	type RX_SM is (IDLE, START_BIT, DATA_BIT, STOP_BIT, PAUSE);
	signal current_state : RX_SM := IDLE;
	signal move_to_next : std_logic := '0';
	--Klokkegenerering
	constant clk_in_bit : integer := (F_CLK/(BAUDRATE*SAMPLING*2));
	signal rx_clk_counter : integer range 0 to CLK_IN_BIT := 0;
	signal rx_clk : std_logic := '0';
	signal period_counter : integer range 0 to SAMPLING-1;
	--Dataavlesning
	signal DATA_INDEX : integer range 0 to DATABITS-1 := 0;
	signal rx_byte		: std_logic_vector(DATABITS-1 downto 0) := (others => '0');
	signal rx_tests 	: std_logic_vector(4 downto 0) := (others => '0');
	
	--Funksjonen returnerar majoriteten av ein 5-bit vektor
	pure function majority_decision(input_vector : std_logic_vector(4 downto 0)) return std_logic is
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
	
	--Funksjonen returnerar verdiar til displayet
	pure function displayValue(n: std_logic_vector) return std_logic_vector is 
		variable Ekran: std_logic_vector(7 downto 0);	
		
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
			--test_clk <= rx_clk;
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
					if period_counter = SAMPLING-1 then
						if move_to_next = '1' then
							current_state <= DATA_BIT;
							period_counter <= 2; --Setter til 2 for å gjøre opp for timing-delays i denne casen
						else
							current_state <= IDLE;
						end if;
					elsif period_counter = SAMPLING/2 then
						if rx_input = '0' then
							move_to_next <= '1';
							period_counter <= period_counter + 1;
							current_state <= START_BIT;
						else
							current_state <= IDLE;
							period_counter <= 0;
						end if;
					else
						period_counter <= period_counter + 1;
					end if;
					
				when DATA_BIT =>
					-- Les av bit med korrekt timing og index
					-- Inkrementer DATA_INDEX
					-- Legg til bit i signalet rx_byte
					--test_rx_tests <= rx_tests;
					if period_counter < SAMPLING-1 then
						if (period_counter < 7) and (period_counter > 1) then
							rx_tests(period_counter-2) <= rx_input;
							--test_sampling <= '1';
						--else
							--test_sampling <= '0'; 
						end if;
						period_counter <= period_counter + 1;
						current_state <= DATA_BIT;
					else
						period_counter <= 0;
						rx_byte(DATA_INDEX) <= majority_decision(rx_tests);
						rx_tests <= "00000";
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

	--Prosessen kontrollerer displayet
	display : process(all)
	begin
		hex1 <=  displayValue(recived_byte(7 downto 4));
		hex0 <=  displayValue(recived_byte(3 downto 0));
	end process;

end architecture;
