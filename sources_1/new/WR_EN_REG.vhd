library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_1b is
  port (
    BitOut  : out std_logic;
    BitData : in  std_logic;
    WriteEn : in  std_logic;
    reset   : in  std_logic;
    clk     : in  std_logic
  );
end entity;

architecture rtl of REG_1b is
  signal q: std_logic := '0';
begin
  BitOut <= q;
  process(clk, reset)
  begin
    if reset = '1' then
      q <= '0';
    elsif rising_edge(clk) then
      if WriteEn = '1' then   -- only write on '1'
        q <= BitData;
      end if;                 -- '0' or 'U' => hold
    end if;
  end process;
end architecture;