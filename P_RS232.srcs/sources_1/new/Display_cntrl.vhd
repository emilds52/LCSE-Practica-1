
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
Data_i: in std_logic_vector(27 downto 0);
Enable: in std_logic;
Data_o: out std_logic_vector(31 downto 0) --4 4 4
);
end component;

signal data_split: std_logic_vector(31 downto 0);

component decoder IS
PORT (
code : IN std_logic_vector(3 DOWNTO 0);
segment : OUT std_logic_vector(6 DOWNTO 0)
);
END component;

signal dig_show: std_logic_vector(3 downto 0);

signal counter : unsigned(15 DOWNTO 0);
signal clk_enable : std_logic;
constant divisor : unsigned(15 DOWNTO 0) := to_unsigned(41666,counter'length); --41666; 20MHz/(41666*8) = 60 hz por dígito

signal dig_count: integer range 0 to 7;

type std_segments_arr is array (7 downto 0) of  std_logic_vector(6 downto 0);
signal Segment_arr: std_segments_arr;

--9999 9999 is 27b (0101111101011110000011111111)
signal sum_t: std_logic_vector(27 downto 0);

signal sum_enable_ant: std_logic;

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

   counter_process: process(clk, reset)
   begin
       if reset='0' then
            clk_enable <= '0';
            counter <= (others=>'0');
       elsif rising_edge(clk) then
           if counter = divisor then
               counter <= (others => '0');
               clk_enable <= '1';
           else
               clk_enable <= '0';
               counter <= counter + 1;
           end if;
       end if;
   end process;   

    display_process: process (clk, reset)
    begin
        if reset='0' then
            digctrl <= (others=>'1');
            dig_count <= 0;
            Segment <= (others=>'1');
        elsif rising_edge(clk) then
            if clk_enable='1' then
                dig_count <= dig_count +1;
                
                -- Clock enables based on counter value
                digctrl <= (others => '1');
                digctrl(dig_count) <= '0';
                
                Segment <= segment_arr(dig_count);
            end if;
        end if;
    end process;

   sum_process: process(clk, reset)
   begin
        if reset='0' then
            sum_t <= (others => '0');
        elsif rising_edge(clk) then
            sum_enable_ant <= sum_enable;
            if (sum_enable /= sum_enable_ant and sum_enable='1') then --flanco de subida de sum_enable, solo suma una vez por pulsación.
                if sum_t > 99999999 then
                    sum_t <= (others=> '0');
                else
                    sum_t <= sum_t + Data;
                end if;
            end if;
        end if;
    end process;
     

end architecture;