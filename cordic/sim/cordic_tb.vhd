library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity cordic_tb is 
end cordic_tb;

architecture testbench of cordic_tb is 
    -- testbench constants and generics
    CONSTANT clk_period     : time      := 10 ns;

    CONSTANT PW_TB          : integer   := 16;   
    CONSTANT XYW_TB          : integer   := 16;
    CONSTANT WW_TB          : integer   := 17;
    CONSTANT N_Stages_TB    : integer   := 4;

    CONSTANT TWOPI      : unsigned(PW_TB-1 downto 0) := to_unsigned(2**(PW_TB)-1,PW_TB);
    CONSTANT PI         : unsigned(PW_TB-1 downto 0) := to_unsigned(2**(PW_TB-1)-1,PW_TB);
    CONSTANT HALFPI     : unsigned(PW_TB-1 downto 0) := to_unsigned(2**(PW_TB-2)-1,PW_TB);
    CONSTANT QUARTERPI  : unsigned(PW_TB-1 downto 0) := to_unsigned(2**(PW_TB-3)-1,PW_TB);

    -- componet under test
    component cordic is
        generic (PW      : integer := PW_TB;         -- Phase Bit Width
                 XYW       : integer := XYW_TB;         -- Data Bit Width
                 WW       : integer := WW_TB;         -- Working Data Width
                 N_Stages : integer := N_Stages_TB  );  -- Number of Rotations
        port (
          clk         :   in      std_logic;
          arst_n      :   in      std_logic; 
          i_phi       :   in      std_logic_vector(PW_TB-1 downto 0); -- unsigned
          i_xval      :   in      std_logic_vector(XYW_TB-1 downto 0); -- signed
          i_yval      :   in      std_logic_vector(XYW_TB-1 downto 0); -- signed
          o_phi       :   out     std_logic_vector(PW_TB-1 downto 0); -- unsigned
          o_xval      :   out     std_logic_vector(XYW_TB-1 downto 0); -- signed
          o_yval      :   out     std_logic_vector(XYW_TB-1 downto 0) -- signed
        ) ;
      end component;
      -- io signals
      signal clk    : std_logic;
      signal arst_n : std_logic;
      signal i_phi  : std_logic_vector(PW_TB-1 downto 0);
      signal i_xval : std_logic_vector(XYW_TB-1 downto 0);
      signal i_yval : std_logic_vector(XYW_TB-1 downto 0);
      signal o_phi  : std_logic_vector(PW_TB-1 downto 0);
      signal o_xval : std_logic_vector(XYW_TB-1 downto 0);
      signal o_yval : std_logic_vector(XYW_TB-1 downto 0);
begin 

        DUT : cordic 
        -- generic map (
        -- PW       => PW_TB,
        -- XYW      => XYW_TB
        -- )
        port map(
            clk    => clk   ,
            arst_n => arst_n,
            i_phi  => i_phi ,
            i_xval => i_xval,
            i_yval => i_yval,
            o_phi  => o_phi ,
            o_xval => o_xval,
            o_yval => o_yval    
        );

        clk_proc : process 
        begin 
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end process;

        tb_main : process
        begin
            arst_n <= '0';
            wait for 200 ns; wait until falling_edge(clk);

            arst_n <='1';
            wait until falling_edge(clk);

            -- TEST 01
            -- looping incr. phase should give sin/cos, f=f_clk
            i_xval <=  (others=>'1');
            i_yval <=  (others=>'0');  

            for i in 0 to 2**(PW_TB)-1 loop 
                i_phi <= i_phi+1;
                wait until falling_edge(clk);
            end loop;
            -- END TEST 01

            wait for 1 us;
            arst_n <= '0';

            wait;  -- end of testbench        
        end process; 
end testbench;