-- Takes in an 8 bit two's complement number
-- Converts to a three digit decimal number
-- Generated by ChatGPT, 14 April 2023
-- Modified by Capt Brian Yarbrough

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity twoscomp_decimal is
    port (
        i_binary: in std_logic_vector(7 downto 0);
        o_negative: out std_logic_vector(3 downto 0);
        o_hundreds: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
end twoscomp_decimal;

architecture Behavioral of twoscomp_decimal is
begin
    process(i_binary)
        variable binary_value: integer;
        variable decimal_value: integer;
    begin
        binary_value := to_integer(signed(i_binary));
        if binary_value < 0 then
            o_negative <= "1111";
            decimal_value := -binary_value;
        else
            o_negative <= "0000";
            decimal_value := binary_value;
        end if;
        
        o_hundreds <= std_logic_vector(to_unsigned(decimal_value/100, 4));
        decimal_value := decimal_value mod 100;
        o_tens <= std_logic_vector(to_unsigned(decimal_value/10, 4));
        decimal_value := decimal_value mod 10;
        o_ones <= std_logic_vector(to_unsigned(decimal_value, 4));
    end process;
end Behavioral;

