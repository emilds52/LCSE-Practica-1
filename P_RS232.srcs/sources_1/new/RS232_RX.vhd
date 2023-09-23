
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity RS232_RX is
port (
    Clk       : in  std_logic;
    Reset     : in  std_logic;
    LineRD_in : in  std_logic;
    Valid_out : out std_logic;
    Code_out  : out std_logic;
    Store_out : out std_logic
);
end RS232_RX;

architecture Behavioral of RS232_RX is
    -- Salidas
    signal Valid_reg : std_logic;
    signal Code_reg  : std_logic;
    signal Store_reg : std_logic;
    signal Valid_tmp : std_logic;
    signal Code_tmp  : std_logic;
    signal Store_tmp : std_logic;
    -- Internos
    constant pulse_width     : unsigned(7 downto 0):=to_unsigned(174,8);
    signal   bitCounter_reg  : unsigned(7 downto 0);
    signal   bitCounter_tmp  : unsigned(7 downto 0);
    signal   data_count_reg  : unsigned(2 downto 0);
    signal   data_count_tmp  : unsigned(2 downto 0);
    signal   stopFlag_reg    : std_logic;
    signal   stopFlag_tmp    : std_logic;

    type state is (idle, StartBit, RcvData, StopBit);
    signal current_state_reg : state;
    signal next_state        : state;

    begin

    comb:process(LineRD_in, current_state_reg, reset, bitCounter_reg, stopFlag_reg, data_count_reg) --process(all) da error de sintaxis no soportado desde 1076-2008
    begin
        bitCounter_tmp <= (others => '0');
        data_count_tmp <= data_count_tmp;
        stopFlag_tmp <= stopFlag_tmp;
        Valid_tmp <= '0';
        Code_tmp <= '0';
        Store_tmp <= '0';
        
        case(current_state_reg) is
        
            when idle =>
            data_count_tmp <= (others => '0');
            stopFlag_tmp <= '0';
                if LineRD_in='0' then
                    next_state <= StartBit;
                end if;
            
            when StartBit =>
                if bitCounter_tmp = pulse_width/2 then
                    bitCounter_tmp <= (others=>'0');
                    next_state <= RcvData;
                else 
                    bitCounter_tmp <= bitCounter_tmp + 1;
                end if;  
            
            when RcvData =>
                if bitCounter_tmp=pulse_width then
                    Valid_tmp <= '1';
                    Code_tmp <= LineRD_in;
                    if data_count_tmp /= to_unsigned(7,data_count_tmp'length) then
                        bitCounter_tmp <= (others=>'0');
                        data_count_tmp <= data_count_tmp +1;
                    else
                        next_state <= StopBit;
                    end if;
                else
                    bitCounter_tmp <= bitCounter_tmp + 1;   
                end if;
                    
            when StopBit =>
                if bitCounter_tmp = pulse_width and stopFlag_tmp='0' then
                    Store_tmp <= LineRD_in;
                    bitCounter_tmp <= (others=>'0');
                    stopFlag_tmp <= '1';
                elsif bitCounter_tmp = pulse_width/2 and stopFlag_tmp='1' then
                    data_count_tmp <= (others => '0');
                    bitCounter_tmp <= (others => '0');
                    stopFlag_tmp <= '0';
                    next_state <= idle;
                else 
                    bitCounter_tmp <= bitCounter_tmp + 1;   
                end if;
            when others =>
        end case ;
    end process;

    reg : process( clk, reset )
    begin
        if reset='0' then
            bitCounter_reg <= (others => '0');
            data_count_reg <= (others => '0');
            stopFlag_reg   <= '0';
            Valid_reg      <= '0';
            Code_reg       <= '0';
            Store_reg      <= '0';
        elsif rising_edge(clk) then
            bitCounter_reg <= bitCounter_tmp;
            data_count_reg <= data_count_tmp;
            stopFlag_reg <= stopFlag_tmp;
            Valid_reg <= Valid_tmp;
            Code_reg <= Code_tmp;
            Store_reg <= Store_tmp;
            current_state_reg <= next_state;
        end if ;
    end process;
    
    Valid_out <= Valid_reg;
    Code_out  <= Code_reg;
    Store_out <= Store_reg;

end Behavioral;
