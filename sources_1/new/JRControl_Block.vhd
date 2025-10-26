-- detects jr instruction so PC can override normal squencing/ jump targets
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity JRControl_Block is
  port (
    JRControl : out std_logic;
    ALUOp     : in  std_logic_vector(1 downto 0);
    JR_function  : in  std_logic_vector(5 downto 0)
  );
end entity;

architecture rtl of JRControl_Block is
begin
  -- JR when R-type and funct = 001000
  process(ALUOp, JR_function)
  begin
    if (ALUOp = "10") and (JR_function = "001000") then
      JRControl <= '1';
    else
      JRControl <= '0';
    end if;
  end process;
end architecture;