library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity SplitDig is
port(
CLK: in std_logic;
Reset: in std_logic;
Data_i: in std_logic_vector(26 downto 0);
Enable: in std_logic;
Data_o: out std_logic_vector(32 downto 0) --4 4 4
);
end SplitDig;

architecture Behavioral of SplitDig is

signal Data_i_uns: unsigned(Data_i'range);
signal Data_o_uns: unsigned(Data_o'range);

begin

Data_i_uns <= unsigned(Data_i);

process(CLK)
begin
    if reset='0' then
        Data_o_uns <= (others=>'0');
    end if;
    
    if rising_edge(clk) then
        if enable='1' then
            --división de 8 a 0 en tres vectores de 4 elementos
            Data_o_uns(3 downto 0) <= Data_i_uns mod 10;
            Data_o_uns(7 downto 4) <= (Data_i_uns mod 100) / 10; --no hace falta hacer mod 10, trunca ((Data_i_uns - (Data_i_uns mod 10))mod 100)
            Data_o_uns(11 downto 8) <= (Data_i_uns mod 1000) / 100;
            Data_o_uns(15 downto 12) <= (Data_i_uns mod 10000) / 1000;
            Data_o_uns(19 downto 16) <= (Data_i_uns mod 100000) / 10000;
            Data_o_uns(23 downto 20) <= (Data_i_uns mod 1000000) / 100000;
            Data_o_uns(27 downto 24) <= (Data_i_uns mod 10000000) / 1000000;
            Data_o_uns(31 downto 28) <= (Data_i_uns mod 100000000) / 10000000;
        end if;
    end if;
end process;

Data_o <= std_logic_vector(Data_o_uns);

end Behavioral;

--for i in 0 to 7 loop
--    Data_o_uns(3+4*i downto 4*i) <= (Data_i_uns mod 10**(i+1))/(10**i);
--end loop;

--            if Data_i_uns >= 200 then
--                Data_o_uns(11 downto 8) <= to_unsigned(2,2);
--            elsif Data_i_uns > 99 then
--                Data_o_uns(11 downto 8) <= to_unsigned(1,2);
--            else
--                Data_o_uns(11 downto 8) <= to_unsigned(0,2);
--            end if;