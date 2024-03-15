----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2023 02:18:06 PM
-- Design Name: 
-- Module Name: seven_segment_decoder_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segment_decoder_tb is
end seven_segment_decoder_tb;

architecture tb of seven_segment_decoder_tb is
    component seven_segment_decoder 
        Port (a,b,c,d : in std_logic;
              a1,a2,a3,a4,a5,a6,a7 : out STD_LOGIC);
    end component;
    signal a,b,c,d : std_logic;
    signal a1,a2,a3,a4,a5,a6,a7 : STD_LOGIC;
begin
    UUT : seven_segment_decoder port map ( a=>a, b=>b, c=>c, d=>d, a1=>a1, a2=>a2, a3=>a3, a4=>a4, a5=>a5, a6=>a6, a7=>a7);
    a <= '0','1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns, '1' after 50 ns, '0' after 60 ns, '1' after 70 ns, '0' after 80 ns, '1' after 90 ns, '0' after 100 ns, '1' after 110 ns, '0' after 120 ns, '1' after 130 ns, '0' after 140 ns, '1' after 150 ns;
    b <= '0','1' after 20 ns, '0' after 40 ns, '1' after 60 ns, '0' after 80 ns, '1' after 100 ns, '0' after 120 ns, '1' after 140 ns;
    c <= '0','1' after 40 ns, '0' after 80 ns, '1' after 120 ns;
    d <= '0','1' after 80 ns;
    
end tb;
