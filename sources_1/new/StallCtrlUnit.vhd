library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity StallControl is
  port (
    PC_WriteEn     : out std_logic;
    IFID_WriteEn   : out std_logic;
    Stall_flush    : out std_logic;
    EX_MemRead     : in  std_logic;
    EX_rt          : in  std_logic_vector(4 downto 0);
    ID_rs          : in  std_logic_vector(4 downto 0);
    ID_rt          : in  std_logic_vector(4 downto 0);
    ID_Op          : in  std_logic_vector(5 downto 0)
  );
end entity;

architecture rtl of StallControl is
  -- MIPS opcodes used in the exception for ID_rt-as-dest
  constant OPC_XORI : std_logic_vector(5 downto 0) := "001110";
  constant OPC_LW   : std_logic_vector(5 downto 0) := "100011";

  signal id_rt_is_source : std_logic := '0';  -- '1' when ID_rt is actually read (not XORI/LW)
  signal hazard_rs       : std_logic := '0';  -- EX_rt == ID_rs
  signal hazard_rt       : std_logic := '0';  -- EX_rt == ID_rt and ID_rt is source
  signal stall_cond      : std_logic := '0';
begin
  -- ID_rt is a source for most ops, except XORI and LW (where rt is the destination)
  id_rt_is_source <= '1' when (ID_Op /= OPC_XORI and ID_Op /= OPC_LW) else '0';

  hazard_rs  <= '1' when (EX_rt = ID_rs) else '0';
  hazard_rt  <= '1' when (EX_rt = ID_rt and id_rt_is_source = '1') else '0';

  stall_cond <= '1' when (EX_MemRead = '1' and (hazard_rs = '1' or hazard_rt = '1')) else '0';

  -- Outputs: freeze PC/IFID on stall, and raise Stall_flush to inject a bubble
  PC_WriteEn   <= not stall_cond;
  IFID_WriteEn <= not stall_cond;
  Stall_flush  <= stall_cond;
end architecture;