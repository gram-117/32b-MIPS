library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sign_extend is
  port (
    sign_ext_out : out std_logic_vector(31 downto 0);
    sign_ext_in  : in  std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of sign_extend is
begin
  sign_ext_out <= (31 downto 16 => sign_ext_in(15)) & sign_ext_in; 
end architecture;