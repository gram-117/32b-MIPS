library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dataMem is
  port (
    data        : out std_logic_vector(31 downto 0);
    address     : in  std_logic_vector(31 downto 0);
    writedata   : in  std_logic_vector(31 downto 0);
    writeenable : in  std_logic;
    MemRead     : in  std_logic;              -- not used here 
    clk         : in  std_logic
  );
end entity;

architecture rtl of dataMem is
  -- 1 KiB byte-addressable RAM
  type ram_t is array (0 to 1023) of std_logic_vector(7 downto 0);
  signal ram  : ram_t := (others => (others => '0'));
  signal temp : std_logic_vector(31 downto 0);

  -- convenience: keep the effective address in range. 
  function to_idx(a: std_logic_vector(31 downto 0)) return integer is
  begin
    -- use lower 10 bits: range 0..1023 (wraps automatically)
    return to_integer(unsigned(a(9 downto 0)));
  end function;

begin
  -- synchronous write (byte-wise), big-endian 
  process(clk)
    variable idx : integer;
  begin
    if rising_edge(clk) then
      if writeenable = '1' then
        idx := to_idx(address);
        ram(idx    ) <= writedata(31 downto 24);
        ram(idx + 1) <= writedata(23 downto 16);
        ram(idx + 2) <= writedata(15 downto  8);
        ram(idx + 3) <= writedata( 7 downto  0);
      end if;
    end if;
  end process;

  -- asynchronous read (comb) of 32-bit word at address
  process(address, ram)
    variable idx : integer;
  begin
    idx := to_idx(address);
    -- big-endian assembly (matches)
    temp <= ram(idx) & ram(idx+1) & ram(idx+2) & ram(idx+3);
  end process;

  -- optional buffer delay could be modeled with "after 1000 ps", but synth ignores it
  data <= temp;
end architecture;