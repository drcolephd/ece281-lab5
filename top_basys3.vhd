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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        --inputs
        clk     : in std_logic; --100MHz native clock
        btnU    : in std_logic; --reset button
        btnC    : in std_logic; --manual advance
        sw      : in std_logic_vector(15 downto 0);
        
        --outputs
        led     : out std_logic_vector(15 downto 0);
        seg     : out std_logic_vector(6 downto 0);
        an      : out std_logic_vector(3 downto 0)
         );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
	
	component Controller_fsm is
	   port(
	           i_reset, i_adv : in std_logic;
	           o_cycle : out std_logic_vector(3 downto 0)
	        );
	end component Controller_fsm;
	
    component TDM4 is
        generic (constant k_WIDTH : natural := 4);
        port(
               i_clk        : in  STD_LOGIC;
               i_reset        : in  STD_LOGIC; -- asynchronous
               i_D3         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D2         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D1         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D0         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_data        : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_sel        : out STD_LOGIC_VECTOR (3 downto 0)    -- selected data line (one-cold)
             );
    end component TDM4; --need a second clock divider apparently for you
        
    component clock_divider is
        generic ( constant k_DIV : natural := 2);
        port(
                i_clk    : in std_logic;
                i_reset  : in std_logic;           -- asynchronous
                o_clk    : out std_logic           -- divided (slow) clock
            );
    end component clock_divider;
    
    component twoscomp_decimal is
        port(
                i_binary: in std_logic_vector(7 downto 0);
                o_negative: out std_logic_vector(3 downto 0);
                o_hundreds: out std_logic_vector(3 downto 0);
                o_tens: out std_logic_vector(3 downto 0);
                o_ones: out std_logic_vector(3 downto 0)
            );
    end component twoscomp_decimal;
        
    component sevenSegDecoder is
        port(
                i_D : in std_logic_vector(3 downto 0);
                o_S : out std_logic_vector(6 downto 0)
            );
    end component sevenSegDecoder;
    
    component ALU is
        port(
                i_A,i_B : out std_logic_vector(7 downto 0);
                i_op : out std_logic_vector(3 downto 0);
                o_flags : out std_logic_vector(2 downto 0);
                o_result : out std_logic_vector(7 downto 0)
            );
    end component ALU;
    
    signal w_clk, w_clk2, w_reset : std_logic;
    signal w_D3, w_D2, w_D1, w_D0 : std_logic_vector (3 downto 0);
    signal w_sel, w_data, w_op : std_logic_vector (3 downto 0);
    signal w_negative, w_hundreds, w_tens, w_ones : std_logic_vector(3 downto 0);
    signal w_A, w_B, w_result, w_bin : std_logic_vector(7 downto 0);
    
begin
	-- PORT MAPS ----------------------------------------
         clkdiv_inst : clock_divider
           generic map ( k_DIV => 25000000)
               port map(
                           i_clk => clk,
                           i_reset => btnU,
                           o_clk => w_clk
                       );
                       
           clkdiv_inst2 : clock_divider
           generic map ( k_DIV => 200000)
               port map(
                           i_clk => clk,
                           i_reset => btnU,
                           o_clk => w_clk2
                       );
        plexer_inst : TDM4
             port map(
                         i_clk => w_clk2,
                         i_reset => btnU,
                         i_D3 => w_negative,
                         i_D2 => w_hundreds,
                         i_D1 => w_tens,
                         i_D0 => w_ones,
                         o_data => w_data,
                         o_sel => an
                      );
           
           decoder_inst : sevenSegDecoder
              port map(
                          i_D => w_data,
                          o_S => seg
                      );
           
        fsm_inst : Controller_fsm
            port map(
                        i_reset => btnU,
                        i_adv => btnC,
                        o_cycle => w_op
                    );
        ALU_inst : ALU
            port map(
                        i_A => w_A,
                        i_B => w_B,
                        i_op => w_op,
                        o_flags => led(15 downto 13),
                        o_result => w_result
                    );
       twoscomp_inst : twoscomp_decimal
            port map(
                        i_binary => w_bin,
                        o_negative => w_negative,
                        o_hundreds => w_hundreds,
                        o_tens => w_tens,
                        o_ones => w_ones
                    );             
	
	-- CONCURRENT STATEMENTS ----------------------------
	process (w_op)
        begin
            if (w_op = "0001") then
                w_A <= sw(7 downto 0);
            end if;
        end process;
	
	process (w_op)
        begin
            if (w_op = "0010") then
                w_B <= sw(7 downto 0);
            end if;
        end process;
	
	w_bin <= w_A when w_op = "0001" else
	         w_B when w_op = "0010" else
	         w_result when w_op = "0100" else
	         "00000000";
	     
	led(3 downto 0) <= w_op;
	led(12 downto 4) <= (others => '0');	
end top_basys3_arch;
