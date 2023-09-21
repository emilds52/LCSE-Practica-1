
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
    Valid_reg : std_logic;
    Code_reg  : std_logic;
    Store_reg : std_logic;
    Valid_tmp : std_logic;
    Code_tmp  : std_logic;
    Store_tmp : std_logic;
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

    comb:process(all)
    begin
        bitCounter_tmp <= (others => '0');
        data_count_tmp <= (others => '0');
        stopFlag_tmp <= '0';
        case(current_state_reg) is
        
            when idle =>
                
            
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
        end if ;
    end process;

    Valid_out <= Valid_reg;
    Code_out  <= Code_reg;
    Store_out <= Store_reg;
end Behavioral;
