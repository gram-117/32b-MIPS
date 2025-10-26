-- forwarding unit avoids pipeline stalls when instruction needs values that are being written to mem or reg
-- takes result straight from ALU
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ForwardingUnit is
  port (
    ForwardA        : out std_logic_vector(1 downto 0); 
    ForwardB        : out std_logic_vector(1 downto 0); 
    MEM_RegWrite    : in  std_logic;
    WB_RegWrite     : in  std_logic;
    MEM_WriteRegister : in  std_logic_vector(4 downto 0);
    WB_WriteRegister  : in  std_logic_vector(4 downto 0);
    EX_rs           : in  std_logic_vector(4 downto 0);
    EX_rt           : in  std_logic_vector(4 downto 0)
  );
end entity;

architecture rtl of ForwardingUnit is
  -- A-path helpers
  signal a, b, x : std_logic;  -- MEM nonzero, MEM==rs, MEM match flag
  signal c, d, y : std_logic;  -- WB  nonzero, WB ==rs, WB  match flag
  -- B-path helpers
  signal b1, d1, x1, y1 : std_logic;  -- compare to rt
begin
  -- ===== A path (EX_rs) =====
  a <= '1' after 50 ps when (MEM_WriteRegister /= "00000") else '0' after 50 ps;
  b <= '1' after 50 ps when (MEM_WriteRegister =  EX_rs   ) else '0' after 50 ps;
  x <= '1' after 50 ps when (MEM_RegWrite = '1' and a = '1' and b = '1') else '0' after 50 ps;

  c <= '1' after 50 ps when (WB_WriteRegister  /= "00000") else '0' after 50 ps;
  d <= '1' after 50 ps when (WB_WriteRegister   =  EX_rs  ) else '0' after 50 ps;
  y <= '1' after 50 ps when (WB_RegWrite  = '1' and c = '1' and d = '1') else '0' after 50 ps;

  ForwardA(1) <= x after 50 ps;
  ForwardA(0) <= (not x) and y after 50 ps;

  -- ===== B path (EX_rt) =====
  b1 <= '1' after 50 ps when (MEM_WriteRegister = EX_rt) else '0' after 50 ps;
  d1 <= '1' after 50 ps when (WB_WriteRegister  = EX_rt) else '0' after 50 ps;

  x1 <= '1' after 50 ps when (MEM_RegWrite = '1' and a = '1' and b1 = '1') else '0' after 50 ps;
  y1 <= '1' after 50 ps when (WB_RegWrite  = '1' and c = '1' and d1 = '1') else '0' after 50 ps;

  ForwardB(1) <= x1 after 50 ps;
  ForwardB(0) <= (not x1) and y1 after 50 ps;
end architecture;