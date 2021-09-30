library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;


entity cordic is
  generic (PB       : integer := 16;  -- Phase Bit Width
           DB       : integer := 16;  -- Data Bit Width
           WW       : integer := 17;  -- Working Data Width
           N_Stages : integer := 4);  -- Number of Rotations
  port (
    clk         :   in      std_logic;
    arst_n      :   in      std_logic; 
    i_phi       :   in      std_logic_vector(PB-1 downto 0); -- unsigned
    i_xval      :   in      std_logic_vector(DB-1 downto 0); -- signed
    i_yval      :   in      std_logic_vector(DB-1 downto 0); -- signed
    o_phi       :   out     std_logic_vector(PB-1 downto 0); -- unsigned
    o_xval      :   out     std_logic_vector(DB-1 downto 0); -- signed
    o_yval      :   out     std_logic_vector(DB-1 downto 0); -- signed
  ) ;
end cordic;


architecture rtl of cordic is 
    CONSTANT TWOPI      : unsigned(PW-1 downto 0) := to_unsigned(2**(PW)-1,PW);
    CONSTANT PI         : unsigned(PW-1 downto 0) := to_unsigned(2**(PW-1)-1,PW);
    CONSTANT HALFPI     : unsigned(PW-1 downto 0) := to_unsigned(2**(PW-2)-1,PW);
    CONSTANT QUARTERPI  : unsigned(PW-1 downto 0) := to_unsigned(2**(PW-3)-1,PW);
    type xy_arr_t is array(N_Stages to 0) of   signed(WW-1 downto 0);
    type ph_arr_t is array(N_Stages to 0) of unsigned(PW-1 downto 0);


    signal e_xval   :   signed(WW-1 downto 0); -- 'extended' values for digital gain
    signal e_yval   :   signed(WW-1 downto 0);
    signal octet    :   std_logic_vector(3 downto 0);
    signal xv       :   xy_arr_t := (others<=(others<='0'));
    signal yv       :   xy_arr_t := (others<=(others<='0'));
    signal ph       :   ph_arr_t := (others<=(others<='0'));
    signal cordic_angles : ph_arr_t := (X"4b90",X"27ec",X"1444",X"a2c");

begin 

main : process( clk,arst_n )
begin
    if arst_n='0' then
        octet <= "XXX";
        xv <= (others=>(others=>'0'));
        yv <= (others=>(others=>'0'));
        ph <= (others=>(others=>'0'));
        o_phi  <= (others=>'0'); 
        o_xval <= (others=>'0');        
        o_yval <= (others=>'0');
    else 
        if rising_edge(clk) then

            e_xval <= resize(signed(i_xval),WW); -- add cordic gain scaling  
            e_yval <= resize(signed(i_yval),WW);
            octet <= phi_i(N-1 downto N-4);

            case octet is 
                when "000"|"111" => -- 0..45, 315..360
                    -- No Change
                    xv[0] <=    e_yval;      
                    yv[0] <=    e_xval;  
                    ph[0] <=    i_phi;
                when "001" => -- 45..90
                    xv[0] <=   -e_yval;
                    yv[0] <=   e_xval;
                    ph[0] <=    i_phi + (PI + HALFPI);
                when "010" => -- 90..135
                    xv[0] <=   -e_yval;
                    yv[0] <=    e_xval;
                    ph[0] <=    i_phi + (PI + HALFPI);
                when "011" => -- 135..180
                    xv[0] <=   -e_xval;
                    yv[0] <=   -e_yval;
                    ph[0] <=    i_phi + PI;
                when "100" => -- 180..225
                    xv[0] <=   -e_xval;
                    yv[0] <=   -e_yval;
                    ph[0] <=    i_phi + PI;
                when "101" => -- 225..270
                    xv[0] <=   e_yval;
                    yv[0] <=    -e_xval;
                    ph[0] <=    i_phi + HALFPI;
                when "110" => -- 270..315
                    xv[0] <=   e_yval;
                    yv[0] <=   -e_xval;                
                    ph[0] <=    i_phi + HALFPI;
                when others =>
                    NULL;
            end case;

            for i in 0 to (N_stages-1) loop
                if (ph[i](PW-1) = 1) 
                    xv[i+1] <= xv[i] + shift_right(yv[i],i+1);
                    yv[i+1] <= yv[i] - shift_right(yv[i],i+1);
                    ph[i+1] <= ph[i] + cordic_angle[i];
                else 
                    xv[i+1] <= xv[i] - shift_right(yv[i],i+1);
                    yv[i+1] <= yv[i] + shift_right(yv[i],i+1);
                    ph[i+1] <= ph[i] - cordic_angle[i];
                end if;
            end loop;

            -- truncating output data...
            o_xval <= std_logic_vector(resize(xv[N_stages],DW));
            o_yval <= std_logic_vector(resize(yv[N_stages],DW));
            o_phi  <= std_logic_vector(ph[N_stages]);

        end if;
    end if;
end process ; -- main


end architecture;