library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2x5to5 is
  port (
    addrOut : out std_logic_vector(4 downto 0);
    addr0   : in  std_logic_vector(4 downto 0);
    addr1   : in  std_logic_vector(4 downto 0);
    m_select  : in  std_logic
  );
end entity;

architecture structural of mux2x5to5 is
begin
  gen_bits : for i in 0 to 4 generate
    u_mux : entity work.mux2to1
      port map (
        O   => addrOut(i),
        A   => addr0(i),
        B   => addr1(i),
        sel => m_select
      );
  end generate;
end architecture;