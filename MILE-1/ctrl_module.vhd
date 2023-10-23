library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_module is
	port(
	data : in std_logic_vector(7 downto 0);  		 -- Input: Binærverdien til ein ASCII-karakter
	hex1, hex0 : out std_logic_vector(7 downto 0) -- Output: Signal til eit 7-segment display
);
end entity;

architecture project of ctrl_module is

	-- Funksjonen tar inn ein 4-bit vektor og returnerar
	-- ein 8-bit vektor tilsvarande 7-segment display verdiar
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
	
	--Kunn for test skal bli del av klokkelogikk i full modul
	process(all)
		begin
		hex1 <=  displayValue(data(7 downto 4));
		hex0 <=  displayValue(data(3 downto 0));
	end process;

end architecture;


