-- handles clock speed for mips processor and the 7 seg display. 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity IO_TOP is
  Port ( 
  
  clk : in std_logic;
  btnC : in std_logic;
  led  : out std_logic_vector(15 downto 0);
  
  seg : out std_logic_vector(6 downto 0); -- 7 seg display
  an  : out std_logic_vector(3 downto 0);
  
  sw : in std_logic_vector(2 downto 0) -- for speed selection
  );
end IO_TOP;

architecture Behavioral of IO_TOP is
    signal sys_clk_i : std_logic;
    signal mips_clk  : std_logic;
    signal rst_i : std_logic;
    signal led_o : std_logic_vector(15 downto 0);
    signal i_switch_1 : std_logic;
    signal i_switch_2 : std_logic;
    signal i_enable : std_logic;
    signal clk_100hz : std_logic;
    signal clk_50hz : std_logic;
    signal clk_10hz : std_logic;
    signal clk_1hz : std_logic;

    signal prescaler_pulse_100 : std_logic := '0';
    signal prescaler_cnt_100 : unsigned(31 downto 0) := (others => '0');
    
    signal prescaler_pulse_50 : std_logic := '0';
    signal prescaler_cnt_50 : unsigned(31 downto 0) := (others => '0');
    
    signal prescaler_pulse_10 : std_logic := '0';
    signal prescaler_cnt_10 : unsigned(31 downto 0) := (others => '0');
    
    signal prescaler_pulse_1 : std_logic := '0';
    signal prescaler_cnt_1 : unsigned(31 downto 0) := (others => '0');
    
    signal fib_num : std_logic_vector(31 downto 0);

begin 
    sys_clk_i <= clk;
    rst_i <= btnC;
    led <= led_o;
    i_enable <= sw(0);
    i_switch_1 <= sw(1);
    i_switch_2 <= sw(2);
    
    -- 100hz prescaler, counter is 
    prescaler_proc_100 : process(sys_clk_i, rst_i)
    begin
        if (rst_i = '1') then
            prescaler_pulse_100 <= '0';
            prescaler_cnt_100 <=  (others => '0');
        elsif rising_edge(sys_clk_i) then
            if prescaler_cnt_100 = 1000000 then  
                prescaler_pulse_100 <= '1';
                prescaler_cnt_100 <= (others => '0');
            else 
                prescaler_pulse_100 <= '0';
                prescaler_cnt_100 <= prescaler_cnt_100 + 1;
            end if;
        end if;
    end process prescaler_proc_100;
    

    -- 50hz prescaler
    prescaler_proc_50 : process(sys_clk_i, rst_i)
    begin
        if (rst_i = '1') then
            prescaler_pulse_50 <= '0';
            prescaler_cnt_50 <=  (others => '0');
        elsif rising_edge(sys_clk_i) then
            if prescaler_cnt_50 = 5000000 then
                prescaler_pulse_50 <= '1';
                prescaler_cnt_50 <= (others => '0');
            else 
                prescaler_pulse_50 <= '0';
                prescaler_cnt_50 <= prescaler_cnt_50 + 1;
            end if;
        end if;
    end process prescaler_proc_50;
    
    -- 10hz prescaler
    prescaler_proc_10 : process(sys_clk_i, rst_i)
    begin
        if (rst_i = '1') then
            prescaler_pulse_10 <= '0';
            prescaler_cnt_10 <=  (others => '0');
        elsif rising_edge(sys_clk_i) then
            if prescaler_cnt_10 = 10000000 then
                prescaler_pulse_10 <= '1';
                prescaler_cnt_10 <= (others => '0');
            else 
                prescaler_pulse_10 <= '0';
                prescaler_cnt_10 <= prescaler_cnt_10 + 1;
            end if;
        end if;
    end process prescaler_proc_10;
    
    -- 1hz prescaler
    prescaler_proc_1 : process(sys_clk_i, rst_i)
    begin
        if (rst_i = '1') then
            prescaler_pulse_1 <= '0';
            prescaler_cnt_1 <=  (others => '0');
        elsif rising_edge(sys_clk_i) then
            if prescaler_cnt_1 = 100000000 then
                prescaler_pulse_1 <= '1';
                prescaler_cnt_1 <= (others => '0');
            else 
                prescaler_pulse_1 <= '0';
                prescaler_cnt_1 <= prescaler_cnt_1 + 1;
            end if;
        end if;
    end process prescaler_proc_1;
    
    mips_clk_gen : process(sys_clk_i)
    begin
        if rising_edge(sys_clk_i) then
            if (i_enable = '1') then
                if (i_switch_1 = '0' and i_switch_2 = '0') then -- 100hz
                    mips_clk <= prescaler_pulse_100;
                elsif (i_switch_1 = '0' and i_switch_2 = '1') then  -- 50hz
                    mips_clk <= prescaler_pulse_50;
                elsif (i_switch_1 = '1' and i_switch_2 = '0') then -- 10hz
                    mips_clk <= prescaler_pulse_10;
                else -- 1hz
                    mips_clk <= prescaler_pulse_1;
                end if;
            end if;
        end if;    
    end process mips_clk_gen;
    
    
    
-- processor
MIPS : entity work.MIPSpipeline
  port map (
    clk  => mips_clk,
    btnC =>  rst_i, 
    led  => led,
    fib_num => fib_num 
  );
-- display 
SEVEN_SEG : entity work.SEVEN_SEG 
  port map (
    clk      => clk,              
    rst      => rst_i,
    data_in  => fib_num,
    an       => an,
    seg      => seg
  );


end Behavioral;
