library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity zero_extend is
  Port (
  zero_ext_out : out std_logic_vector(31 downto 0);
  zero_ext_in  : in std_logic_vector(15 downto 0)
  );
end zero_extend;

architecture Behavioral of zero_extend is

begin

zero_ext_out <= (15 downto 0 => '0') & zero_ext_in;

end Behavioral;
