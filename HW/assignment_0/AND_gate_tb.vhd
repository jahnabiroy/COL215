----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2023 12:56:08 AM
-- Design Name: 
-- Module Name: AND_gate_tb - Behavioral
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

entity AND_gate_tb is
end AND_gate_tb;

architecture tb of AND_gate_tb is
    component AND_gate 
        Port ( a: in std_logic;
               b: in std_logic;
               c: out std_logic);
    end component;
    signal a,b : std_logic;
    signal c : std_logic;
begin
    UUT : AND_gate port map (a => a, b => b, c => c);
    a <= '0','1' after 20 ns, '0' after 40 ns, '1' after 60 ns;
    b <= '0','1' after 40 ns;

end tb;
