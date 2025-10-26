library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADDER is
  port (
    sum  : out std_logic;
    cout : out std_logic;
    a, b, cin : in std_logic
  );
end entity;

architecture gates of ADDER is
  signal c1, c2, c3 : std_logic;
begin
  sum  <= a xor b xor cin after 50 ps;
  c1   <= a and b         after 50 ps;
  c2   <= a or  b         after 50 ps;
  c3   <= c2 and cin      after 50 ps;
  cout <= c1 or  c3       after 50 ps;
end architecture;