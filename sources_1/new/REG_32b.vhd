library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_32b is
  port (
    RegOut  : out std_logic_vector(31 downto 0);
    RegIn   : in  std_logic_vector(31 downto 0);
    WriteEn : in  std_logic;
    reset   : in  std_logic;
    clk     : in  std_logic
  );
end entity;

architecture struct of REG_32b is
begin
  gen_bits : for i in 0 to 31 generate
    b : entity work.REG_1b
      port map (
        BitOut  => RegOut(i),
        BitData => RegIn(i),
        WriteEn => WriteEn,
        reset   => reset,
        clk     => clk
      );
  end generate;
end architecture;
