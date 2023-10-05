
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Display_cntrl is
port(
CLK: in std_logic;
RESET: in std_logic;
Sum_enable: in std_logic;
Data: in std_logic_vector(7 downto 0);
Digctrl : out std_logic_vector(7 DOWNTO 0);
Segment : out std_logic_vector(6 DOWNTO 0)
);
end Display_cntrl;

architecture Behavioral of Display_cntrl is

component SplitDig is
port(
CLK: in std_logic;
Reset: in std_logic;
Data_i: in std_logic_vector(26 downto 0);
Enable: in std_logic;
Data_o: out std_logic_vector(31 downto 0) --4 4 4
);
end component;

signal data_split: std_logic_vector(11 downto 0);

component decoder IS
PORT (
code : IN std_logic_vector(3 DOWNTO 0);
segment : OUT std_logic_vector(6 DOWNTO 0)
);
END component;

signal dig_show: std_logic_vector(3 downto 0);

signal counter : std_logic_vector(19 DOWNTO 0) := (others => '0');
signal clk_enable : std_logic := '0';
signal clk_bcd : std_logic_vector(7 DOWNTO 0) := (others => '0');
constant divisor : std_logic_vector(19 DOWNTO 0) := x"1B207";

signal dig_count: integer range 0 to 7;

type std_arr is array (4 downto 0) of  std_logic_vector(6 downto 0);
signal Segment_arr: std_arr;

--9999 9999 is 27b (101111101011110000011111111)
signal sum_t: std_logic_vector(26 downto 0);
signal sum_t_uns: unsigned(26 downto 0);

BEGIN

splitDig_inst: SplitDig
port map(
CLk => CLK,
Reset => reset,
Data_i => sum_t,
Enable => Sum_enable,
Data_o => Data_split
);

decoder_generate: for i in 0 to 7 generate
decoder_inst: Decoder
port map(
code => Data_split(3+4*i downto 4*i),
segment => Segment_arr(i)
);
end generate decoder_generate;

   counter_process: process(clk)
   begin
       if rising_edge(clk) then
           if counter = divisor then
               counter <= (others => '0');
               clk_enable <= '1';
           else
               clk_enable <= '0';
               counter <= counter + 1;
           end if;
       end if;
   end process;   

   display_process: process (clk)
   begin
       if rising_edge(clk_enable) then
           dig_count <= dig_count +1;
           
           -- Clock enables based on counter value
           digctrl <= (others => '1');
           digctrl(dig_count) <= '0';
           
           Segment <= segment_arr(dig_count);
       end if;
   end process;
   
   sum_process: process(clk, reset)
   begin
        if reset='0' then
            sum_t_uns <= (others => '0');
        elsif rising_edge(clk) then
            if sum_enable='1' then
                    if sum_t_uns > 99999999 then
                        sum_t_uns <= (others=> '0');
                    else
                        sum_t_uns <= sum_t_uns + unsigned(Data);
                    end if;
            end if;
        end if;
    end process;
    
    sum_t <= std_logic_vector(sum_t_uns);

end architecture;