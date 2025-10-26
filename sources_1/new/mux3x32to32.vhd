library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux3x32to32 is
  port (
    DataOut : out std_logic_vector(31 downto 0);
    A, B, C : in  std_logic_vector(31 downto 0);
    mux32_select  : in  std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of mux3x32to32 is
begin
  -- 00→A, 10→B, 01→C, 11→A (fallback)
  with mux32_select select
    DataOut <= A when "00",
               B when "10",
               C when "01",
               A when others;   -- "11" never produced; safe default
end architecture;