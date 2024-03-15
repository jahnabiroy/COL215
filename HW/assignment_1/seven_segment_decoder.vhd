----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/02/2023 12:08:00 AM
-- Design Name: 
-- Module Name: seven_segment_decoder - Behavioral
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

entity seven_segment_decoder is
    Port ( a,b,c,d : in STD_LOGIC;
           a1,a2,a3,a4,a5,a6,a7,b1,b2,b3 : out STD_LOGIC);
end seven_segment_decoder;

architecture Behavioral of seven_segment_decoder is

begin

a1 <= not(((not a) and (not b) and (not c) and (not d)) or (c and (not a)) or ((not a) and b and d) or (a and b and c) or((a) and (not b) and (not c)) or ( a and c and (not d)) or (a and (not c) and (not d)));

a2 <= not(((not a) and (not b)) or ((not a) and (not c) and (not d)) or (a and (not c) and d) or(a and (not b) and (not c)) or ((not a) and b and c and d) or (a and (not b) and c and (not d)));

a3 <= not(((not a) and (not c)) or ((not a )and c and d) or ((not a) and b) or ((not c) and d) or(a and (not b)));

a4 <= not(((not a) and (not b) and (not c) and (not d)) or (b and c and (not d)) or (a and (not c)) or (a and (not b) and d) or (b and (not c) and d) or ((not a) and (not b) and c));

a5 <= not((c and (not d)) or (a and b) or (a and c) or ((not a) and (not b) and (not c) and (not d)) or (a and (not c) and (not d)));

a6 <= not(((not c) and (not d)) or (a and (not b)) or ((not a) and b and (not c))or ( a and b and c) or ( b and c and (not d)));

a7 <= not((a and (not b)) or (c and (not d)) or ((not a) and (not b) and c) or (a and b and d) or ((not a) and b and (not c)));

b1 <= '1';
b2 <= '1';
b3 <= '1';


end Behavioral;
