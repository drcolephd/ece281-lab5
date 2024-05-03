--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|     SUB     001
--|     AND     010
--|      OR     011
--|     LSH     100
--|     RSH     101
--|
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
    port(
            i_A,i_B : out std_logic_vector(7 downto 0);
            i_op : out std_logic_vector(3 downto 0);
            o_flags : out std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(7 downto 0)
        );
end ALU;

architecture behavioral of ALU is 
  
	-- declare components and signals
            signal w_A, w_B : std_logic_vector(7 downto 0);
            signal w_op : std_logic_vector(3 downto 0);
            signal w_led : std_logic_vector(2 downto 0);
            signal w_result : std_logic_vector(7 downto 0);
  
begin
	-- PORT MAPS ----------------------------------------
            i_A <= w_A;
            i_B <= w_B;
            i_op <= w_op;
            o_flags <= w_led;
	
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	
	o_result <= std_logic_vector(not(( not(unsigned(w_A)+1) + ( not(unsigned(w_B)+1) ) )-1)) when w_op = "000" else
	            std_logic_vector(not(( not(unsigned(w_A)+1) + ( not(unsigned(w_B)+1) ) )-1)) when w_op = "001" else
	            w_A and w_B when w_op = "010" else
	            w_A or w_B when w_op = "011" else
	            std_logic_vector(shift_left(unsigned(w_A), to_integer(unsigned(w_B(2 downto 0))))) when w_op = "100" else
	            std_logic_vector(shift_right(unsigned(w_A), to_integer(unsigned(w_B(2 downto 0))))) when w_op = "101" else
	            "00000000";
	
	
end behavioral;
