library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DEC5TO32 is
  port (
    dec_out : out std_logic_vector(31 downto 0);
    Adr : in  std_logic_vector(4 downto 0)
  );
end entity;

architecture rtl of DEC5TO32 is
begin
  process(Adr)
    variable tmp : std_logic_vector(31 downto 0);
  begin
    tmp := (others => '0');
    tmp(to_integer(unsigned(Adr))) := '1';
    dec_out <= tmp;
  end process;
end architecture;