
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

begin


end Behavioral;
