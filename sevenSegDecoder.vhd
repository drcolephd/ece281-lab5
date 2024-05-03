----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2024 01:21:15 PM
-- Design Name: 
-- Module Name: sevenSegDecoder - Behavioral
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

entity sevenSegDecoder is
port(
    i_D : in std_logic_vector(3 downto 0);
    o_S : out std_logic_vector(6 downto 0)
    );
    
end sevenSegDecoder;

architecture Behavioral of sevenSegDecoder is
begin
    process(i_D)
        begin
            case i_D is
                when "0000" => o_S <= "1000000"; --0
                when "0001" => o_S <= "1111001"; -- 1
                when "0010" => o_S <= "0100100"; -- 2
                when "0011" => o_S <= "0110000"; -- 3
                when "0100" => o_S <= "0011001"; -- 4
                when "0101" => o_S <= "0010010"; -- 5
                when "0110" => o_S <= "0000010"; -- 6
                when "0111" => o_S <= "1111000"; -- 7
                when "1000" => o_S <= "0000000"; -- 8
                when "1001" => o_S <= "0010000"; -- 9
--                when "01010" => o_S <= "0001000"; -- 10
--                when "01011" => o_S <= "0000011"; -- 11
--                when "01100" => o_S <= "1000110"; -- 12
--                when "01101" => o_S <= "0100001"; -- 13
--                when "01110" => o_S <= "0000110"; -- 14
--                when "01111" => o_S <= "0001110"; -- 15
                when "1111" => o_S <= "01111111"; -- negative sign
                when others => o_S <= "1111111"; -- off
            end case;
    end process;

end Behavioral;