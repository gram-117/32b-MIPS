library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder1bit is
  port (
    sum  : out std_logic;
    cout : out std_logic;
    a    : in  std_logic;
    b    : in  std_logic;
    cin  : in  std_logic
  );
end entity;

architecture gates of adder1bit is
  signal c1, c2, c3, axb : std_logic;
begin
  -- sum = a xor b xor cin
  axb  <= a xor b;   
  sum  <= axb xor cin;

  -- carry out = a.b + cin.(a+b)
  c1   <= a and b;
  c2   <= a or  b;
  c3   <= c2 and cin;
  cout <= c1 or  c3;
end architecture;