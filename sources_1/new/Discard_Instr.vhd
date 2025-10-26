library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Discard_Instr is
  port (
    ID_flush : out std_logic;
    IF_flush : out std_logic;
    jump     : in  std_logic;
    bne      : in  std_logic;
    jr       : in  std_logic
  );
end entity;

architecture rtl of Discard_Instr is
begin
  IF_flush <= jump or bne or jr;  -- flush IF on any redirect
  ID_flush <= bne  or jr;         -- flush ID for EX-resolved redirects
end architecture;