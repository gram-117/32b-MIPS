library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SEVEN_SEG is
  port(
    clk     : in  std_logic;                     -- 100 MHz
    rst     : in  std_logic;
    data_in : in  std_logic_vector(31 downto 0); -- number to show
    an      : out std_logic_vector(3 downto 0);  -- digit anodes (active-low)
    seg     : out std_logic_vector(6 downto 0)   -- segments g..a (active-low)
  );
end entity;

architecture rtl of SEVEN_SEG is
  signal refresh_cnt : unsigned(15 downto 0) := (others => '0');
  signal scan        : unsigned(1 downto 0);
  signal onehot      : unsigned(3 downto 0);
  signal val         : unsigned(31 downto 0);
  signal d0,d1,d2,d3 : unsigned(3 downto 0);
  signal dig         : unsigned(3 downto 0);
begin
  val <= unsigned(data_in);

  -- lowest 4 decimal digits
  d0 <= resize(val            mod 10, 4);
  d1 <= resize((val/10)   mod 10, 4);
  d2 <= resize((val/100)  mod 10, 4);
  d3 <= resize((val/1000) mod 10, 4);

  -- ~1.5 kHz per digit (100 MHz / 2^16 / 4)
  process(clk, rst) begin
    if rst='1' then
      refresh_cnt <= (others => '0');
    elsif rising_edge(clk) then
      refresh_cnt <= refresh_cnt + 1;
    end if;
  end process;

  scan   <= refresh_cnt(15 downto 14);
  onehot <= shift_left(to_unsigned(1,4), to_integer(scan));
  an     <= not std_logic_vector(onehot);  -- enable one digit (active-low)

  -- select digit value (rightmost = scan 0)
  with scan select dig <=
    d0 when "00",
    d1 when "01",
    d2 when "10",
    d3 when others;

  -- 0-9 decoder for **GFEDCBA** (active-low)
  process(dig) begin
    case dig is
      when "0000" => seg <= "1000000"; -- 0
      when "0001" => seg <= "1111001"; -- 1
      when "0010" => seg <= "0100100"; -- 2
      when "0011" => seg <= "0110000"; -- 3
      when "0100" => seg <= "0011001"; -- 4
      when "0101" => seg <= "0010010"; -- 5
      when "0110" => seg <= "0000010"; -- 6
      when "0111" => seg <= "1111000"; -- 7
      when "1000" => seg <= "0000000"; -- 8
      when "1001" => seg <= "0010000"; -- 9
      when others => seg <= "1111111"; -- blank
    end case;
  end process;
end architecture;