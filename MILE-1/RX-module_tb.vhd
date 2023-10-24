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
   constant BIT_PERIOD : time := 104 us;  -- 9600bit per sekund 
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
		recived_byte : out std_logic_vector(DATABITS-1 downto 0);
      test_clk : out std_logic
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
   signal test_clk : std_logic;
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
      recived_byte => recived_byte,
      test_clk => test_clk
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

   p_data: process
   begin
   rx_input <= '1';
   wait for BIT_PERIOD*2;
   --STARTBIT
   rx_input <= '0';
   wait for BIT_PERIOD;
   --DATABIT 10 10 10 10
   --0
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --1
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --2
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --3
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --4
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --5
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --6
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --7
   rx_input <= not rx_input;
   wait for BIT_PERIOD;
   --STOPPBIT
   --0
   rx_input <= '0';
   wait for BIT_PERIOD;
   --PAUSE
   rx_input <= '1';
   wait for BIT_PERIOD*6;
   
   assert recived_byte = "10101010" report "Wrong result given testbench" severity error;

   assert false report "Testbench finished" severity failure;
   end process p_data;


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

