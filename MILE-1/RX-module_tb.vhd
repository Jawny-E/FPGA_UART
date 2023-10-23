library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rx_module_tb is 
end rx_module_tb;

architecture test of rx_module_tb is
   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------
   constant CLK_PER  : time    := 20 ns;    -- 50 MHz
   constant DATABITS : integer := 8;

   -----------------------------------------------------------------------------
   -- Component declarasion
   -----------------------------------------------------------------------------
   component rx_module is
      generic (
        F_CLK 		 : integer := 50000000; 	--50mHz (Hz)
	BAUDRATE 	 : integer := 9600; 	 		--Gitt baudrate(bit/s)
	SAMPLING 	 : integer := 8;				--Sampling per periode(per bit)
	DATABITS 		 : integer := 8		
	);
      port (
		clk: in  std_logic;
		rx_input  	 : in std_logic;							  		  -- Seriellt signal
		recived_flag : out std_logic;							  		  -- Flagg for mottat byte
		recived_byte : out std_logic_vector(DATABITS-1 downto 0)
         );
   end component rx_module;


   -----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
   signal clk : std_logic;
   signal rx_input :  std_logic;
   signal recived_flag : std_logic;
   signal recived_byte : std_logic_vector(DATABITS-1 downto 0);
   -- Testbench signals
  

begin

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   i_rx_module: component rx_module
   port map (
      clk     => clk,
      rx_input => rx_input,
      recived_flag => recived_flag,
      recived_byte => recived_byte
   );


   -----------------------------------------------------------------------------
   -- purpose: control the clk-signal
   -- type   : sequential
   -- inputs : 
   -----------------------------------------------------------------------------
   p_clk: process
   begin
      clk <= '0';
      wait for CLK_PER/2;
      clk <= '1';
      wait for CLK_PER/2;
   end process p_clk;



   -----------------------------------------------------------------------------
   -- purpose: Main process
   -- type   : sequential
   -- inputs : 
   -----------------------------------------------------------------------------
   --p_main: process
   --begin

 
   --   assert false report "Testbench finished" severity failure;

   --end process p_main;
end test;

