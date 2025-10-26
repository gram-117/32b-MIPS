library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WB_forward is
  port (
    ReadData1Out  : out std_logic_vector(31 downto 0);
    ReadData2Out  : out std_logic_vector(31 downto 0);
    ReadData1     : in  std_logic_vector(31 downto 0);
    ReadData2     : in  std_logic_vector(31 downto 0);
    rs            : in  std_logic_vector(4 downto 0);
    rt            : in  std_logic_vector(4 downto 0);
    WriteRegister : in  std_logic_vector(4 downto 0);
    WriteData     : in  std_logic_vector(31 downto 0);
    RegWrite      : in  std_logic
  );
end entity;

architecture rtl of WB_forward is
  signal write_nonzero : std_logic;
  signal match_rs      : std_logic;
  signal match_rt      : std_logic;
  signal read_src_rs   : std_logic;
  signal read_src_rt   : std_logic;
begin
  -- WB dest is not $zero
  write_nonzero <= '1' when WriteRegister /= "00000" else '0';

  -- Address matches
  match_rs <= '1' when WriteRegister = rs else '0';
  match_rt <= '1' when WriteRegister = rt else '0';

  -- Forwarding conditions
  read_src_rs <= '1' when (RegWrite = '1' and write_nonzero = '1' and match_rs = '1') else '0';
  read_src_rt <= '1' when (RegWrite = '1' and write_nonzero = '1' and match_rt = '1') else '0';

  -- Select between regfile reads and WB write data
  ReadData1Out <= WriteData when read_src_rs = '1' else ReadData1;
  ReadData2Out <= WriteData when read_src_rt = '1' else ReadData2;
end architecture;