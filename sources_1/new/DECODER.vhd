library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DECODER is
  port (
    WriteEn      : out std_logic_vector(31 downto 0); -- per reg wr_en
    RegWrite     : in  std_logic; -- global wr_en
    WriteRegister: in  std_logic_vector(4 downto 0) -- which reg
  );
end entity;

architecture rtl of DECODER is
  signal OE : std_logic_vector(31 downto 0);
begin
  DEC: entity work.DEC5TO32 port map(dec_out => OE, Adr => WriteRegister);

  WriteEn(0) <= '0'; -- $zero stays 0 
  gen_we : for i in 1 to 31 generate
    WriteEn(i) <= OE(i) and RegWrite after 50 ps;
  end generate;
end architecture;