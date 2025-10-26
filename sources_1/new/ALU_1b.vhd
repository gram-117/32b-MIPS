library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_1b is
  port (
    result     : out std_logic;
    crrout     : out std_logic;
    a, b       : in  std_logic;
    carryin    : in  std_logic;
    less       : in  std_logic;                -- only bit0 uses this for SLT
    ALUControl : in  std_logic_vector(1 downto 0) -- select between arithmetic and logic result
  );
end entity;

architecture rtl of ALU_1b is
  signal addsubOut, xorOut, xorlessOut : std_logic;
begin
  U_ADD: entity work.ADDSUB
    port map (as_out => addsubOut, cout => crrout, a => a, b => b, cin => carryin, as_select => ALUControl(1));

  xorOut     <= a xor b after 50 ps;
  xorlessOut <= xorOut when ALUControl(1)='0' else less;         -- mux21

  result     <= addsubOut when ALUControl(0)='0' else xorlessOut; -- mux21
end architecture;