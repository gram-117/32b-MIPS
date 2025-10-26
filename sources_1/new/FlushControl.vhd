
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flush_block is
  port (
    -- Masked outputs to ID/EX
    ID_RegDst   : out std_logic;
    ID_ALUSrc   : out std_logic;
    ID_MemtoReg : out std_logic;
    ID_RegWrite : out std_logic;
    ID_MemRead  : out std_logic;
    ID_MemWrite : out std_logic;
    ID_Branch   : out std_logic;
    ID_ALUOp    : out std_logic_vector(1 downto 0);
    ID_JRControl: out std_logic;
    -- Flush control and raw ID controls
    flush       : in  std_logic;
    RegDst      : in  std_logic;
    ALUSrc      : in  std_logic;
    MemtoReg    : in  std_logic;
    RegWrite    : in  std_logic;
    MemRead     : in  std_logic;
    MemWrite    : in  std_logic;
    Branch      : in  std_logic;
    ALUOp       : in  std_logic_vector(1 downto 0);
    JRControl   : in  std_logic
  );
end entity;

architecture rtl of flush_block is
  signal notflush : std_logic;
begin
  notflush <= not flush;  -- add "after 50 ps" if you want sim delay

  ID_RegDst    <= RegDst    and notflush;
  ID_ALUSrc    <= ALUSrc    and notflush;
  ID_MemtoReg  <= MemtoReg  and notflush;
  ID_RegWrite  <= RegWrite  and notflush;
  ID_MemRead   <= MemRead   and notflush;
  ID_MemWrite  <= MemWrite  and notflush;
  ID_Branch    <= Branch    and notflush;
  ID_JRControl <= JRControl and notflush;

  ID_ALUOp(1)  <= ALUOp(1)  and notflush;
  ID_ALUOp(0)  <= ALUOp(0)  and notflush;
end architecture;