
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shiftregister is
port(
CLK: in std_logic;
RESET: in std_logic;
ENABLE: in std_logic;
D: in std_logic;

Q:out std_logic_vector(7 downto 0)
);
end shiftregister;

architecture Behavioral of shiftregister is
    signal q_aux: std_logic_vector(7 downto 0) := (others => '0');
begin
    process(CLK)
    begin
        if RESET = '0' then
            q_aux <= (others => '0');
        elsif rising_edge(CLK) then
            if ENABLE = '1' then
                q_aux <= q_aux(6 downto 0) & D;
            end if;
        end if;
    end process;
    Q <= q_aux;
end Behavioral;

