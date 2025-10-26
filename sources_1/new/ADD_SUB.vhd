library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADDSUB is -- (as)
  port (
    as_out    : out std_logic;
    cout   : out std_logic;
    a, b   : in  std_logic;
    cin    : in  std_logic;
    as_select : in  std_logic               -- 0:add, 1:sub
  );
end entity;

architecture rtl of ADDSUB is
  signal b1, notb : std_logic;
begin
  notb <= not b after 50 ps;
  b1   <= b when as_select='0' else notb;   -- mux21

  U_FA: entity work.ADDER
    port map (sum => as_out, cout => cout, a => a, b => b1, cin => cin);
end architecture;