-- issue with reading / using same variables that need to be output :(
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
  port (
    Output     : out std_logic_vector(31 downto 0);
    CarryOut   : out std_logic;
    Zero       : out std_logic;
    overflow   : out std_logic;
    negative   : out std_logic;
    BussA      : in  std_logic_vector(31 downto 0);
    BussB      : in  std_logic_vector(31 downto 0);
    ALUControl : in  std_logic_vector(1 downto 0)
  );
end entity;

architecture struct of ALU is
  signal less, notcr31, addsub31Out, crrout31_d : std_logic;
  signal crrout : std_logic_vector(31 downto 0);
  signal r_overflow : std_logic; -- overflow signal internal
  signal r_output : std_logic_vector(31 downto 0);
begin
  -- bit0: carryin comes from ALUControl(1) 
  alu0 : entity work.ALU_1b
    port map ( result => r_output(0), crrout => crrout(0),
               a => BussA(0), b => BussB(0),
               carryin => ALUControl(1), less => less, ALUControl => ALUControl );

  gen_slices : for i in 1 to 31 generate
  begin
    u : entity work.ALU_1b
      port map ( result => r_output(i), crrout => crrout(i),
                 a => BussA(i), b => BussB(i),
                 carryin => crrout(i-1), less => '0', ALUControl => ALUControl );
  end generate;
  
  -- drive top lv output from internal signal
  overflow <= r_overflow; 
  Output <= r_output; 

  -- CarryOut: invert on subtraction
  notcr31  <= not crrout(31) after 50 ps;
  CarryOut <= crrout(31) when ALUControl(1)='0' else notcr31;

  -- Overflow
  r_overflow <= crrout(30) xor crrout(31) after 50 ps;

  -- Recompute MSB add/sub result for SLT correction
  add31 : entity work.ADDSUB
    port map ( as_out => addsub31Out, cout => crrout31_d,
               a => BussA(31), b => BussB(31), cin => crrout(30), as_select => ALUControl(1) );

  -- less = overflow XOR MSBsum  (signed compare)
  less <= r_overflow xor addsub31Out after 50 ps;

  -- Flags
  negative <= r_output(31);
  Zero <= '1' when r_output = X"00000000" else '0';
end architecture;