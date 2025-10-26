library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2x32to32 is
  port (
    DataOut : out std_logic_vector(31 downto 0);
    Data0   : in  std_logic_vector(31 downto 0);
    Data1   : in  std_logic_vector(31 downto 0);
    Sel     : in  std_logic
  );
end entity;

architecture rtl of mux2x32to32 is
begin
  DataOut <= Data1 when Sel = '1' else Data0;
end architecture;