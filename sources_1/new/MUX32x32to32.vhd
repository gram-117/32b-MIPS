library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux32x32to32 is
  port (
    ReadData    : out std_logic_vector(31 downto 0);
    In0,  In1,  In2,  In3,  In4,  In5,  In6,  In7  : in std_logic_vector(31 downto 0);
    In8,  In9,  In10, In11, In12, In13, In14, In15 : in std_logic_vector(31 downto 0);
    In16, In17, In18, In19, In20, In21, In22, In23 : in std_logic_vector(31 downto 0);
    In24, In25, In26, In27, In28, In29, In30, In31 : in std_logic_vector(31 downto 0);
    ReadRegister: in  std_logic_vector(4 downto 0)
  );
end entity;

architecture struct of mux32x32to32 is
  type arr32x32_t is array (0 to 31) of std_logic_vector(31 downto 0);
  signal ArrayReg : arr32x32_t;  -- ArrayReg(j) is a 32-bit "column" of bit j from all inputs
begin
  -- Build the 32 columns 
  process(In0,In1,In2,In3,In4,In5,In6,In7,In8,In9,In10,In11,In12,In13,In14,In15,
          In16,In17,In18,In19,In20,In21,In22,In23,In24,In25,In26,In27,In28,In29,In30,In31)
  begin
    for j in 0 to 31 loop
      ArrayReg(j)(31) <= In31(j);
      ArrayReg(j)(30) <= In30(j);
      ArrayReg(j)(29) <= In29(j);
      ArrayReg(j)(28) <= In28(j);
      ArrayReg(j)(27) <= In27(j);
      ArrayReg(j)(26) <= In26(j);
      ArrayReg(j)(25) <= In25(j);
      ArrayReg(j)(24) <= In24(j);
      ArrayReg(j)(23) <= In23(j);
      ArrayReg(j)(22) <= In22(j);
      ArrayReg(j)(21) <= In21(j);
      ArrayReg(j)(20) <= In20(j);
      ArrayReg(j)(19) <= In19(j);
      ArrayReg(j)(18) <= In18(j);
      ArrayReg(j)(17) <= In17(j);
      ArrayReg(j)(16) <= In16(j);
      ArrayReg(j)(15) <= In15(j);
      ArrayReg(j)(14) <= In14(j);
      ArrayReg(j)(13) <= In13(j);
      ArrayReg(j)(12) <= In12(j);
      ArrayReg(j)(11) <= In11(j);
      ArrayReg(j)(10) <= In10(j);
      ArrayReg(j)(9)  <= In9(j);
      ArrayReg(j)(8)  <= In8(j);
      ArrayReg(j)(7)  <= In7(j);
      ArrayReg(j)(6)  <= In6(j);
      ArrayReg(j)(5)  <= In5(j);
      ArrayReg(j)(4)  <= In4(j);
      ArrayReg(j)(3)  <= In3(j);
      ArrayReg(j)(2)  <= In2(j);
      ArrayReg(j)(1)  <= In1(j);
      ArrayReg(j)(0)  <= In0(j);
    end loop;
  end process;

  -- 32 one-bit muxes (one per bit)
  gen_mux : for j in 0 to 31 generate
    m : entity work.MUX32TO1
      port map (
        mux_out    => ReadData(j),
        InVec  => ArrayReg(j),
        mux_select => ReadRegister
      );
  end generate;
end architecture;