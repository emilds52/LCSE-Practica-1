
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RS232_TX is
    port (
      Clk    : in  std_logic;
      Reset  : in  std_logic;
      Start  : in  std_logic;
      Data   : in  std_logic_vector(7 downto 0);
      Speed  : in  std_logic_vector(1 downto 0);
      N_bits : in  std_logic_vector(1 downto 0);
      EOT    : out std_logic;
      TX     : out std_logic
      );
end RS232_TX;

architecture Behavioral of RS232_TX is

signal TX_reg  : std_logic;
signal EOT_reg : std_logic;

type state is (idle, StartBit, SendData, StopBit);
signal current_state_reg : state;

type speed_t is (quarter, half, normal, doble);
constant pulse_width_default : unsigned(7 downto 0):=to_unsigned(174,8); -- si ponemos nombre a 174 queda m�s entendible, y podemos hacer ceil(log2(174 + 1)) para obtener 7 sin que sea un "n�mero magico" que no se sabe de d�nde viene. No es muy importante pero puede ser algo que se puede hacer en las mejoras si te apetece, igual nos hace sacar una nota mejor.
signal pulse_width_reg : unsigned(10 downto 0); -- TODO hazlo más generico
signal pulse_count_reg : unsigned(7 downto 0);
signal data_count_reg  : unsigned(2 downto 0);

begin
FSM:process(clk)
begin
    if rising_edge(clk) then
        if reset = '0' then
            TX_reg            <= '1';
            current_state_reg <= idle;
            pulse_width_reg   <= pulse_width_default - 1;
        else
            case current_state_reg is
                when idle=>
                    -- Configuraciónes
                    case( Speed ) is
                        when quarter =>
                            pulse_width_reg <= pulse_width_default*4 - 1;
                        
                        when half =>
                            pulse_width_reg <= pulse_width_default*2 - 1;

                        when normal =>
                            pulse_width_reg <= pulse_width_default - 1;

                        when doble =>
                            pulse_width_reg <= pulse_width_default/2 - 1;

                        when others =>
                    end case ;

                    with N_bits select
                    N_bits_reg <= 
                    if start='1' then
                        current_state_reg <= StartBit;
                        pulse_count_reg   <= (others=>'0');
                    end if;
                    
                when StartBit=>
                    if pulse_count_reg = "00000000" then
                        TX_reg          <= '0';
                        pulse_count_reg <= pulse_count_reg + 1;
                    elsif pulse_count_reg = pulse_width_reg then
                        current_state_reg <= SendData;
                        pulse_count_reg   <= (others=>'0');
                        data_count_reg    <= (others=>'0');
                    else
                        pulse_count_reg <= pulse_count_reg + 1;
                    end if;
                    
                when SendData=>
                    if pulse_count_reg = "00000000" then
                        TX_reg          <= data(to_integer(data_count_reg));
                        pulse_count_reg <= pulse_count_reg + 1; 
                    elsif pulse_count_reg = pulse_width_reg then
                        pulse_count_reg <= (others=>'0');
                        if data_count_reg = "111" then
                            current_state_reg <= StopBit;
                        else
                            data_count_reg <= data_count_reg + 1;
                        end if;
                    else
                        pulse_count_reg <= pulse_count_reg + 1;
                    end if;
                    
                when StopBit=>
                    if pulse_count_reg = "00000000" then
                        TX_reg          <= '1';
                        data_count_reg  <= (others=>'0');
                        pulse_count_reg <= pulse_count_reg + 1;
                    elsif pulse_count_reg = pulse_width_reg then
                        current_state_reg <= idle;
                        pulse_count_reg   <= (others=>'0');
                    else
                        pulse_count_reg <= pulse_count_reg + 1;
                    end if;
                    
            end case;
        end if;
    end if;
end process;

    -- Registro de EOT (No tiene que ser registrado, podemos ponerlo como l�gica combinacional, pero as� habr� glitches y supongo que eso no lo queremos. Por otro lado nos deja quitar registros, as� haciendo que sea m�s r�pido y ocupe menos espacio. Con el consumo de potencia no s� si va a consumir m�s o menos, eso depender�a del resto del circuito. Tambi�n supongo que no tenerlo registrado va a hacer el timing dificil, y ser�a mejor pr�ctica tenerlo registrado.) 
EOT_process:PROCESS(clk)
BEGIN
    IF rising_edge(clk) THEN
        if reset='0' then
            EOT_reg <= '1';
        else
            if current_state_reg=idle then
                EOT_reg <= '1';
            else 
                EOT_reg <= '0';
            end if;
        END IF;
    END IF;
END PROCESS;
        
    -- Outputs:
    TX  <= TX_reg;
    EOT <= EOT_reg;

end Behavioral;