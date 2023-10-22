library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_module is
	generic(
	F_CLK 		 : integer := 50_000_000; 	--50mHz (Hz)
	BAUDRATE 	 : integer := 9600; 	 		--Gitt baudrate(bit/s)
	SAMPLING : integer := 8;					--Sampling per periode(per bit)
	DATABIT 		 : integer := 8;				--Bit i ein pakke
	PARITET 		 : std_logic := '0';			--'0' for paritetssjekk av
	PARITET_OP	 : std_logic := '0'			--'0' for partal, '1' for oddetal 
	);
	
	port(
		clk 			 : in std_logic;							  		  -- Intern klokke	
		rx_input  	 : in std_logic;							  		  -- Seriellt signal
		recived_flag : out std_logic;							  		  -- Flagg for mottat byte
		recived_byte : out std_logic_vector(DATABIT-1 downto 0) -- Motatt byte
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
	--Dataavlesning
	signal DATA_INDEX : integer range 0 to DATABIT-1 := 0;
	signal rx_byte		: std_logic_vector(DATABIT-1 downto 0) := (others => '0');
	
	
	begin
	
	-- Prosessen genererer klokkesignal som har frekvens tilsvarande samplingsrate
	clk_generator : process(clk)
	begin
		if rising_edge(clk) then
			if(rx_clk_counter = CLK_IN_BIT) then
				rx_clk <= not rx_clk;
				rx_clk_counter <= 0;
			else
				rx_clk_counter <= rx_clk_counter + 1;
			end if;
		end if;
	end process;

end architecture;
