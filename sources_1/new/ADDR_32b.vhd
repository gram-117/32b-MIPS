library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Add is
  port (
    S : out std_logic_vector(31 downto 0); -- Sum
    A : in  std_logic_vector(31 downto 0);
    B : in  std_logic_vector(31 downto 0)
  );
end entity;

architecture struct of Add is
  component adder1bit
    port (
      sum  : out std_logic;
      cout : out std_logic;
      a    : in  std_logic;
      b    : in  std_logic;
      cin  : in  std_logic
    );
  end component;

  signal C : std_logic_vector(31 downto 0);
begin
  adder1bit0 : adder1bit port map(sum=>S(0),  cout=>C(0),  a=>A(0),  b=>B(0),  cin=>'0');
  adder1bit1 : adder1bit port map(sum=>S(1),  cout=>C(1),  a=>A(1),  b=>B(1),  cin=>C(0));
  adder1bit2 : adder1bit port map(sum=>S(2),  cout=>C(2),  a=>A(2),  b=>B(2),  cin=>C(1));
  adder1bit3 : adder1bit port map(sum=>S(3),  cout=>C(3),  a=>A(3),  b=>B(3),  cin=>C(2));
  adder1bit4 : adder1bit port map(sum=>S(4),  cout=>C(4),  a=>A(4),  b=>B(4),  cin=>C(3));
  adder1bit5 : adder1bit port map(sum=>S(5),  cout=>C(5),  a=>A(5),  b=>B(5),  cin=>C(4));
  adder1bit6 : adder1bit port map(sum=>S(6),  cout=>C(6),  a=>A(6),  b=>B(6),  cin=>C(5));
  adder1bit7 : adder1bit port map(sum=>S(7),  cout=>C(7),  a=>A(7),  b=>B(7),  cin=>C(6));
  adder1bit8 : adder1bit port map(sum=>S(8),  cout=>C(8),  a=>A(8),  b=>B(8),  cin=>C(7));
  adder1bit9 : adder1bit port map(sum=>S(9),  cout=>C(9),  a=>A(9),  b=>B(9),  cin=>C(8));
  adder1bit10: adder1bit port map(sum=>S(10), cout=>C(10), a=>A(10), b=>B(10), cin=>C(9));
  adder1bit11: adder1bit port map(sum=>S(11), cout=>C(11), a=>A(11), b=>B(11), cin=>C(10));
  adder1bit12: adder1bit port map(sum=>S(12), cout=>C(12), a=>A(12), b=>B(12), cin=>C(11));
  adder1bit13: adder1bit port map(sum=>S(13), cout=>C(13), a=>A(13), b=>B(13), cin=>C(12));
  adder1bit14: adder1bit port map(sum=>S(14), cout=>C(14), a=>A(14), b=>B(14), cin=>C(13));
  adder1bit15: adder1bit port map(sum=>S(15), cout=>C(15), a=>A(15), b=>B(15), cin=>C(14));
  adder1bit16: adder1bit port map(sum=>S(16), cout=>C(16), a=>A(16), b=>B(16), cin=>C(15));
  adder1bit17: adder1bit port map(sum=>S(17), cout=>C(17), a=>A(17), b=>B(17), cin=>C(16));
  adder1bit18: adder1bit port map(sum=>S(18), cout=>C(18), a=>A(18), b=>B(18), cin=>C(17));
  adder1bit19: adder1bit port map(sum=>S(19), cout=>C(19), a=>A(19), b=>B(19), cin=>C(18));
  adder1bit20: adder1bit port map(sum=>S(20), cout=>C(20), a=>A(20), b=>B(20), cin=>C(19));
  adder1bit21: adder1bit port map(sum=>S(21), cout=>C(21), a=>A(21), b=>B(21), cin=>C(20));
  adder1bit22: adder1bit port map(sum=>S(22), cout=>C(22), a=>A(22), b=>B(22), cin=>C(21));
  adder1bit23: adder1bit port map(sum=>S(23), cout=>C(23), a=>A(23), b=>B(23), cin=>C(22));
  adder1bit24: adder1bit port map(sum=>S(24), cout=>C(24), a=>A(24), b=>B(24), cin=>C(23));
  adder1bit25: adder1bit port map(sum=>S(25), cout=>C(25), a=>A(25), b=>B(25), cin=>C(24));
  adder1bit26: adder1bit port map(sum=>S(26), cout=>C(26), a=>A(26), b=>B(26), cin=>C(25));
  adder1bit27: adder1bit port map(sum=>S(27), cout=>C(27), a=>A(27), b=>B(27), cin=>C(26));
  adder1bit28: adder1bit port map(sum=>S(28), cout=>C(28), a=>A(28), b=>B(28), cin=>C(27));
  adder1bit29: adder1bit port map(sum=>S(29), cout=>C(29), a=>A(29), b=>B(29), cin=>C(28));
  adder1bit30: adder1bit port map(sum=>S(30), cout=>C(30), a=>A(30), b=>B(30), cin=>C(29));
  adder1bit31: adder1bit port map(sum=>S(31), cout=>C(31), a=>A(31), b=>B(31), cin=>C(30));
end architecture;