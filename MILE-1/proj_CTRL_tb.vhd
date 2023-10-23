library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ALL;



-- Entity n shizzle

entity proj_CTRL_tb is

end proj_CTRL_tb;



-- Architcture

architecture sim of proj_CTRL_tb is

	-- Input/Output signaldeklarasjon

	signal data: std_logic_vector(7 downto 0);
	signal hex1, hex2: std_logic_vector(7 downto 0);
	
begin

	-- Device Under Test (DUT)
	
	i_proj_CTRL_tb: entity work.CTRL_module
	port map (
		data => data,
		hex1 => hex1,
		hex2 => hex2
	);

	
	
	-- "Stimulus process" for å lage testvektorer
	stim_proc: process
	begin
	
		-- Initier signaler
		wait for 100 ns;
        
		-- Test 1: data = "00100011"
		data <= "00100011";
		wait for 100 ns;
		
		assert (hex1 = "10100100") and (hex2 = "10110000")	-- Sjekk om riktig, hex1 = 2 og hex2 = 3
		report "Test case 1 failed" severity error;	-- Dersom hex ikke blir riktig

		-- Test case 2: data = "01010101"
		data <= "01010101";
		wait for 100 ns;
		
		assert (hex1 = "10100100") and (hex2 = "10100100")	-- 5 på begge
		report "Test case 2 failed" severity error;

		wait;  -- Vent til verden går under for å sjekke om det er riktig
	end process;

end sim;
