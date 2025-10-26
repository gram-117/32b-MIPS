library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_left_2 is
  port (
    sl_out32 : out std_logic_vector(31 downto 0);
    sl_in32  : in  std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of shift_left_2 is
begin
  sl_out32 <= sl_in32(29 downto 0) & "00";
end architecture;