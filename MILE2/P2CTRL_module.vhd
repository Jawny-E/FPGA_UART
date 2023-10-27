library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

entity P2CTRL_module is
	Port (
	
		clk     : in  std_logic;
		rst_n   : in  std_logic;							-- Actice low reset
		rx_data : in  std_logic_vector(7 downto 0);	-- Mottatt data fra RX, fra RX-modul
		rx_rdy  : in  std_logic;							-- RX data klar, ---||---
		tx_data : out std_logic_vector(7 downto 0);	-- Data å sende igjennom TX
		tx_rdy  : out std_logic;							-- Klar til å sende
		push_btn: in  std_logic								-- Knappeinput
		
	);
end P2CTRL_module;




architecture RTL of P2CTRL_module is

	signal tx_busy : std_logic := '0'; -- Indukasjon på om TX er opptatt
	signal predefined_char : std_logic_vector(7 downto 0) := "00001000"; -- '8'
	 
begin

	process(clk, rst_n)
	begin
		if rst_n = '0' then
			tx_rdy <= '0';
			tx_busy <= '0';
			
		elsif rising_edge(clk) then
		
            -- Ta imot RX
			if rx_rdy = '1' then
				tx_data <= rx_data;   	-- Tilsendt data ---> data som skal sendes
				tx_rdy <= '1';        	-- Data klar til å sendes
				tx_busy <= '1';       	-- TX opptatt
			end if;

            -- Knappetrykk
			if push_btn = '1' then
				tx_data <= predefined_char; -- Send testchar
				tx_rdy <= '1';              -- Klar til å sende
				tx_busy <= '1';             -- TX opptatt
			end if;
            
			if tx_busy = '1' then
				-- Send TX (panikk)
				tx_busy <= '0';	-- TX klar
				
			end if;   
		end if;
	end process;
end RTL;
