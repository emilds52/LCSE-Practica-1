library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity SplitDig is
port(
CLK: in std_logic;
Reset: in std_logic;
Data_i: in std_logic_vector(26 downto 0);
Enable: in std_logic;
Data_o: out std_logic_vector(31 downto 0) --4 4 4
);
end SplitDig;

architecture Behavioral of SplitDig is

begin

process(CLK, reset)
begin
    if reset='0' then
        Data_o <= (others=>'0');
    elsif rising_edge(clk) then
        if enable='1' then
            --división de 8 a 0 en tres vectores de 4 elementos
            for i in 0 to 7 loop
                Data_o(3+4*i downto 4*i) <= std_logic_vector(resize((unsigned(Data_i) mod 10**(i+1))/(10**i),4));
            end loop;
        end if;
    end if;
end process;

end Behavioral;

--            otra forma de hacerlo equivalente
--            Data_o_uns(3 downto 0) <= resize(Data_i_uns mod 10,4);
--            Data_o_uns(7 downto 4) <= resize((Data_i_uns mod 100) / 10,4); --no hace falta hacer mod 10, trunca ((Data_i_uns - (Data_i_uns mod 10))mod 100)
--            Data_o_uns(11 downto 8) <= resize((Data_i_uns mod 1000) / 100,4);
--            Data_o_uns(15 downto 12) <= resize((Data_i_uns mod 10000) / 1000,4);
--            Data_o_uns(19 downto 16) <= resize((Data_i_uns mod 100000) / 10000,4);
--            Data_o_uns(23 downto 20) <= resize((Data_i_uns mod 1000000) / 100000,4);
--            Data_o_uns(27 downto 24) <= resize((Data_i_uns mod 10000000) / 1000000,4);
--            Data_o_uns(31 downto 28) <= resize((Data_i_uns mod 100000000) / 10000000,4);