library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MIPSStimulus is
end entity;

architecture tb of MIPSStimulus is
  -- Clock period (5000 ps = 5 ns)
  constant ClockDelay : time := 10000 ps;

  signal clk   : std_logic := '0';
  signal btnC : std_logic := '0'; -- rst
  signal led   : std_logic_vector(15 downto 0);

  -- Instantiate the DUT (Design Under Test)
  component MIPSpipeline
    port (
      clk   : in  std_logic;
      btnC : in  std_logic;
      led : out std_logic_vector(15 downto 0)
    );
  end component;

begin
  -- DUT instance
  uut: MIPSpipeline
    port map (
      clk   => clk,
      btnC => btnC,
      led => led
    );

  -- Clock process
  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for ClockDelay / 2;
      clk <= '1';
      wait for ClockDelay / 2;
    end loop;
  end process;

  -- Reset pulse
  reset_process: process
  begin
    -- Better reset sequence in your testbench
    btnC <= '1';
    -- hold for a few full cycles
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    -- deassert halfway through a cycle so comb nets settle before next edge
    wait for (ClockDelay/2);
    btnC <= '0';
    -- also give it one extra cycle before you expect PC to update
    wait for (ClockDelay * 100);
    wait until rising_edge(clk);
  end process;

end architecture;