library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX32TO1 is
  port (
    mux_out    : out std_logic;
    InVec  : in  std_logic_vector(31 downto 0);
    mux_select : in  std_logic_vector(4 downto 0)
  );
end entity;

architecture rtl of MUX32TO1 is
  signal OE : std_logic_vector(31 downto 0); -- one-hot select vector
  signal f  : std_logic_vector(31 downto 0); -- gated inputs 
  -- OR-reduce helper
  function or_reduce(v : std_logic_vector) return std_logic is
    variable r : std_logic := '0';
  begin
    for k in v'range loop
      r := r or v(k);
    end loop;
    return r;
  end function;
begin
  DEC: entity work.DEC5TO32 port map(dec_out => OE, Adr => mux_select);

  gen_and : for i in 0 to 31 generate
    f(i) <= OE(i) and InVec(i) after 50 ps;
  end generate;

  mux_out <= or_reduce(f) after 50 ps;
end architecture;