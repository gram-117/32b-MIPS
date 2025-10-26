library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2to1 is
  port ( 
  O: out std_logic; 
  A,B,sel: in std_logic 
  );
end entity;

architecture gates of mux2to1 is
  signal nsel, O1, O2 : std_logic;
begin
  nsel <= not sel after 50 ps;
  O1   <= A and nsel after 50 ps;
  O2   <= B and sel  after 50 ps;
  O    <= O1 or O2   after 50 ps;
end architecture;