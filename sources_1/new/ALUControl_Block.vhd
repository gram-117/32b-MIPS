-- after main control, outputs to ALU 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUControl_Block is
  port (
    ALUControl : out std_logic_vector(1 downto 0);
    ALUOp      : in  std_logic_vector(1 downto 0);
    ALU_Function   : in  std_logic_vector(5 downto 0)
  );
end entity;

architecture rtl of ALUControl_Block is
begin
  -- Combinational decode
  process(ALUOp, ALU_Function)
  begin
    -- default
    ALUControl <= "00";  -- ADD as safe default

    case ALUOp is
      when "11" =>            -- XORI
        ALUControl <= "01";   -- XOR

      when "00" =>            -- lw/sw
        ALUControl <= "00";   -- ADD

      when "01" =>            -- beq/bne
        ALUControl <= "10";   -- SUB

      when "10" =>            -- R-type: look at Function
        case ALU_Function is
          when "100000" =>    -- ADD
            ALUControl <= "00";
          when "100010" =>    -- SUB
            ALUControl <= "10";
          when "101010" =>    -- SLT
            ALUControl <= "11";
          when others =>
            ALUControl <= "00"; -- default for unlisted functs
        end case;

      when others =>
        ALUControl <= "00";
    end case;
  end process;
end architecture;