library ieee;
use ieee.std_logic_1164.ALL;



-- Entity

entity ctrl_module_tb is
end ctrl_module_tb;

architecture sim of ctrl_module_tb is

   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------
  constant SEG7_0 : std_logic_vector(7 downto 0) := "11000000";
  constant SEG7_1 : std_logic_vector(7 downto 0) := "11111001";
  constant SEG7_2 : std_logic_vector(7 downto 0) := "10100100";
  constant SEG7_3 : std_logic_vector(7 downto 0) := "10110000";
  constant SEG7_4 : std_logic_vector(7 downto 0) := "10011001";
  constant SEG7_5 : std_logic_vector(7 downto 0) := "10010010";
  constant SEG7_6 : std_logic_vector(7 downto 0) := "10000010";
  constant SEG7_7 : std_logic_vector(7 downto 0) := "11111000";
  constant SEG7_8 : std_logic_vector(7 downto 0) := "10000000";
  constant SEG7_9 : std_logic_vector(7 downto 0) := "10010000";
  constant SEG7_A : std_logic_vector(7 downto 0) := "10001000";
  constant SEG7_B : std_logic_vector(7 downto 0) := "10000011";
  constant SEG7_C : std_logic_vector(7 downto 0) := "11000110";
  constant SEG7_D : std_logic_vector(7 downto 0) := "10100001";
  constant SEG7_E : std_logic_vector(7 downto 0) := "10000110";
  constant SEG7_F : std_logic_vector(7 downto 0) := "10001110";

   -----------------------------------------------------------------------------
   -- Component declarasion
   -----------------------------------------------------------------------------
   component ctrl_module is
      port (
	 data : in std_logic_vector(7 downto 0);
	 hex1 : out std_logic_vector(7 downto 0);
	 hex0 : out std_logic_vector(7 downto 0)
         );
   end component ctrl_module;


   -----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
   signal data : std_logic_vector(7 downto 0);
   signal hex1 : std_logic_vector(7 downto 0);
   signal hex0 : std_logic_vector(7 downto 0);
   -- Testbench signals
  

begin

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   i_ctrl_module: component ctrl_module
   port map (
      data     => data,
      hex1     => hex1,
      hex0     => hex0
   );

   -----------------------------------------------------------------------------
   -- purpose: Main process
   -- type   : sequential
   -- inputs : 
   -----------------------------------------------------------------------------
   p_main: process
   begin
      data <= "00010000"; -- hex0: 0 & hex1: 1
      wait for 5 ns;
      assert hex0 = SEG7_0 report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_1 report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;

      data <= "00110010"; -- hex0: 2 & hex1: 3
      wait for 5 ns;
      assert hex0 = SEG7_2 report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_3 report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;
 
      data <= "01010100"; -- hex0: 4 & hex1: 5
      wait for 5 ns;
      assert hex0 = SEG7_4 report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_5 report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;

      data <= "01110110"; -- hex0: 6 & hex1: 7
      wait for 5 ns;
      assert hex0 = SEG7_6 report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_7 report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;

      data <= "10011000"; -- hex0: 8 & hex1: 9
      wait for 5 ns;
      assert hex0 = SEG7_8 report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_9 report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;

      data <= "10111010"; -- hex0: A & hex1: B
      wait for 5 ns;
      assert hex0 = SEG7_A report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_B report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;

      data <= "11011100"; -- hex0: C & hex1: D
      wait for 5 ns;
      assert hex0 = SEG7_C report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_D report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;
            
       data <= "11111110"; -- hex0: E & hex1: F
      wait for 5 ns;
      assert hex0 = SEG7_E report "Wrong setting for 7-segment (0)" severity error;
      assert hex1 = SEG7_F report "Wrong setting for 7-segment (1)" severity error;
      wait for 5 ns;

      assert false report "Testbench finished" severity failure;

   end process p_main;
end architecture sim;

