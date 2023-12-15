library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity SplitDig is
port(
CLK: in std_logic;
Reset: in std_logic;
Data_i: in std_logic_vector(27 downto 0);
Enable: in std_logic;
Data_o: out std_logic_vector(31 downto 0) --4 4 4
);
end SplitDig;

architecture Behavioral of SplitDig is

signal Data_i_aux : unsigned(0 to Data_i'length-1);
signal Data_o_aux : std_logic_vector(0 to Data_o'length-1);
signal resto : unsigned(0 to 6);
signal i : integer range 0 to 15;
begin

reverse_o_gen: for i in 0 to data_o'length-1 generate
  data_o(i) <= data_o_aux(data_o'length-1 - i);
end generate;

process(CLK, reset)
begin
    if reset='0' then
        Data_o_aux <= (others=>'0');
    elsif rising_edge(clk) then
        if enable='0' then  
          i <= 15;
          Data_i_aux <= (others =>'0');
          resto  <= (others=>'0');
        else
          if i = 15 then
            reverse_i_gen: for i in 0 to data_i'length-1 loop
              data_i_aux(i) <= data_i(data_i'length-1 - i);
            end loop;
            i <= 0;
          end if;
          if i < 8 then
            if i = 0 or i <= 6 then
              --división de 8 a 0 en tres vectores de 4 elementos                    
                if Data_i_aux(4*i to 3+4*i) + resto > 9 then
                  Data_o_aux(4*i to 3+4*i) <= std_logic_vector(to_unsigned(9,4));
                  Data_i_aux <= resize(Data_i_aux - 9, Data_i_aux'length);
                  resto <= resize(resto + Data_i_aux(4*i to 3+4*i) - 9, resto'length);
                else
                  Data_o_aux(4*i to 3+4*i) <= std_logic_vector(resize(Data_i_aux(4*i to 3+4*i) + resto, 4));
                  Data_i_aux <= resize(Data_i_aux - Data_i_aux(4*i to 3+4*i) - resto, Data_i_aux'length);
                  resto <= (others=>'0');
                end if;
                i <= i + 1;
            else
              Data_o_aux(28 to 31) <= std_logic_vector(resize(Data_i_aux + resto, 4));
              resto <= (others => '0');
              i <= 12;
            end if;
          end if;
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