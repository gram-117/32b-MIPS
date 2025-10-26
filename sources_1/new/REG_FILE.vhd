library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_FILE is
  port (
    ReadData1     : out std_logic_vector(31 downto 0);
    ReadData2     : out std_logic_vector(31 downto 0);
    WriteData     : in  std_logic_vector(31 downto 0);
    ReadReg1 : in  std_logic_vector(4 downto 0);
    ReadReg2 : in  std_logic_vector(4 downto 0);
    WriteReg : in  std_logic_vector(4 downto 0);
    RegWrite      : in  std_logic;
    reset         : in  std_logic;
    clk           : in  std_logic;
    
    fib_num : out std_logic_vector(31 downto 0)
  );
end entity;

architecture struct of REG_FILE is
  signal WriteEn  : std_logic_vector(31 downto 0);
  type reg_array_t is array (0 to 31) of std_logic_vector(31 downto 0);
  signal RegArray : reg_array_t := (others => (others => '0'));
begin
  -- Write enable decoder (one-hot, R0 disabled)
  DEC: entity work.decoder
    port map (WriteEn => WriteEn, RegWrite => RegWrite, WriteRegister => WriteReg);

  -- r0 = 0 forever
  RegArray(0) <= (others => '0');
  
  -- output fib for display:
  fib_num <= RegArray(10);

  -- r1..r31 registers (sync write, async read via muxes)
  gen_regs : for i in 1 to 31 generate
    ri : entity work.REG_32b
      port map (
        RegOut  => RegArray(i),
        RegIn   => WriteData,
        WriteEn => WriteEn(i),
        reset   => reset,
        clk     => clk
      );
  end generate;

  -- Read port 1
  MUX1: entity work.mux32x32to32
    port map (
      ReadData => ReadData1,
      In0  => RegArray(0),  In1  => RegArray(1),  In2  => RegArray(2),  In3  => RegArray(3),
      In4  => RegArray(4),  In5  => RegArray(5),  In6  => RegArray(6),  In7  => RegArray(7),
      In8  => RegArray(8),  In9  => RegArray(9),  In10 => RegArray(10), In11 => RegArray(11),
      In12 => RegArray(12), In13 => RegArray(13), In14 => RegArray(14), In15 => RegArray(15),
      In16 => RegArray(16), In17 => RegArray(17), In18 => RegArray(18), In19 => RegArray(19),
      In20 => RegArray(20), In21 => RegArray(21), In22 => RegArray(22), In23 => RegArray(23),
      In24 => RegArray(24), In25 => RegArray(25), In26 => RegArray(26), In27 => RegArray(27),
      In28 => RegArray(28), In29 => RegArray(29), In30 => RegArray(30), In31 => RegArray(31),
      ReadRegister => ReadReg1
    );

  -- Read port 2
  MUX2: entity work.mux32x32to32
    port map (
      ReadData => ReadData2,
      In0  => RegArray(0),  In1  => RegArray(1),  In2  => RegArray(2),  In3  => RegArray(3),
      In4  => RegArray(4),  In5  => RegArray(5),  In6  => RegArray(6),  In7  => RegArray(7),
      In8  => RegArray(8),  In9  => RegArray(9),  In10 => RegArray(10), In11 => RegArray(11),
      In12 => RegArray(12), In13 => RegArray(13), In14 => RegArray(14), In15 => RegArray(15),
      In16 => RegArray(16), In17 => RegArray(17), In18 => RegArray(18), In19 => RegArray(19),
      In20 => RegArray(20), In21 => RegArray(21), In22 => RegArray(22), In23 => RegArray(23),
      In24 => RegArray(24), In25 => RegArray(25), In26 => RegArray(26), In27 => RegArray(27),
      In28 => RegArray(28), In29 => RegArray(29), In30 => RegArray(30), In31 => RegArray(31),
      ReadRegister => ReadReg2
    );
end architecture;