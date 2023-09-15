
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RS232_TX is
    port (
      Clk   : in  std_logic;
      Reset : in  std_logic;
      Start : in  std_logic;
      Data  : in  std_logic_vector(7 downto 0);
      EOT   : out std_logic;
      TX    : out std_logic);
end RS232_TX;

architecture Behavioral of RS232_TX is
signal EOT_tmp:std_logic;
signal TX_tmp:std_logic;
type state is (idle, StartBit, SendData, StopBit);
signal current_state_reg: state;
signal next_state: state;
signal TX_reg, EOT_reg: std_logic;

constant pulse_width:unsigned(7 downto 0):=to_unsigned(174,8);
signal pulse_count_reg:unsigned(7 downto 0):=(others=>'0');
signal data_count_reg:unsigned(2 downto 0);

begin
process(clk)
begin
    if rising_edge(clk) then
        if reset='0' then
            EOT_tmp <= '0';
            TX_tmp <= '0';
--            data_count_reg <= (others=>'0');  --Opcional
        else
            if current_state_reg=idle then
                EOT_tmp <= '1';
            else
                EOT_tmp <= '0';
            end if;
            
            case current_state_reg is
                when idle=>
                    if start='1' then
                        next_state <= StartBit;
                        pulse_count_reg<=(others=>'0');
                    end if;
                    
                when StartBit=>
                    if pulse_count_reg = "00000000" then
                        TX_tmp <= '0';
                    elsif pulse_count_reg = pulse_width then
                        next_state <= SendData;
                        pulse_count_reg <= (others=>'0');
                        data_count_reg <= (others=>'0');
                    else
                        pulse_count_reg <= pulse_count_reg + 1;
                    end if;
                    
                when SendData=>
                    if pulse_count_reg = "00000000" then
                        TX_tmp <= data(to_integer(data_count_reg));
                    elsif pulse_count_reg = pulse_width then
                        if data_count_reg = "111" then
                            next_state <= StopBit;
                        else
                            data_count_reg <= data_count_reg + 1;
                        end if;
                        pulse_count_reg <= (others=>'0');
                    else
                        pulse_count_reg <= pulse_count_reg + 1;
                    end if;
                    
                when StopBit=>
                    if pulse_count_reg = "00000000" then
                        TX_tmp <= '1';
                    elsif pulse_count_reg = pulse_width then
                        next_state <= idle;
                        pulse_count_reg <= (others=>'0');
                    else
                        pulse_count_reg <= pulse_count_reg + 1;
                    end if;
                    
            end case;
        end if;
    end if;
end process;

    -- Registro de estado y salidas registradas
output:PROCESS(clk)
BEGIN
    IF clk'event AND clk='1' THEN
        if reset='0' then
            EOT_reg <= '1';
            TX_reg <= '0';
            current_state_reg <= idle;
        else
            current_state_reg <= next_state;
            EOT_reg <= EOT_tmp;
            TX_reg <= TX_tmp;
        END IF;
    END IF;
END PROCESS;
    
    TX <= TX_reg;
    EOT <= EOT_reg;

end Behavioral;
