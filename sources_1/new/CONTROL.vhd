library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control is
  port (
    RegDst     : out std_logic;
    ALUSrc     : out std_logic;
    MemtoReg   : out std_logic;
    RegWrite   : out std_logic;
    MemRead    : out std_logic;
    MemWrite   : out std_logic;
    Branch     : out std_logic;
    ALUOp      : out std_logic_vector(1 downto 0);
    Jump       : out std_logic;
    SignZero   : out std_logic;
    Opcode     : in  std_logic_vector(5 downto 0)
  );
end entity;

architecture rtl of Control is
begin
  -- Purely combinational decode
  process(Opcode) is
  begin
    -- Defaults (safe NOP-like)
    RegDst   <= '0';
    ALUSrc   <= '0';
    MemtoReg <= '0';
    RegWrite <= '0';
    MemRead  <= '0';
    MemWrite <= '0';
    Branch   <= '0';
    ALUOp    <= "10";  -- default could be "10" or "00" depending on ALUCtrl design
    Jump     <= '0';
    SignZero <= '0';

    case Opcode is
      -- R-type: 000000
      when "000000" =>
        RegDst   <= '1';
        ALUSrc   <= '0';
        MemtoReg <= '0';
        RegWrite <= '1';
        MemRead  <= '0';
        MemWrite <= '0';
        Branch   <= '0';
        ALUOp    <= "10";
        Jump     <= '0';
        SignZero <= '0';

      -- LW: 100011
      when "100011" =>
        RegDst   <= '0';
        ALUSrc   <= '1';
        MemtoReg <= '1';
        RegWrite <= '1';
        MemRead  <= '1';
        MemWrite <= '0';
        Branch   <= '0';
        ALUOp    <= "00";
        Jump     <= '0';
        SignZero <= '0';  -- sign-extend offset

      -- SW: 101011
      when "101011" =>
        -- don't-cares shown as 'X' if you like (many tools treat as DC in synth)
        RegDst   <= '0';              -- unused
        ALUSrc   <= '1';
        MemtoReg <= '0';              -- unused
        RegWrite <= '0';
        MemRead  <= '0';
        MemWrite <= '1';
        Branch   <= '0';
        ALUOp    <= "00";
        Jump     <= '0';
        SignZero <= '0';

      -- BNE: 000101
      when "000101" =>
        RegDst   <= '0';
        ALUSrc   <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';
        MemRead  <= '0';
        MemWrite <= '0';
        Branch   <= '1';
        ALUOp    <= "01"; -- SUB for compare
        Jump     <= '0';
        SignZero <= '0';  -- sign-extend branch offset

      -- XORI: 001110
      when "001110" =>
        RegDst   <= '0';
        ALUSrc   <= '1';
        MemtoReg <= '0';
        RegWrite <= '1';
        MemRead  <= '0';
        MemWrite <= '0';
        Branch   <= '0';
        ALUOp    <= "11"; -- route to XOR op
        Jump     <= '0';
        SignZero <= '1';  -- zero-extend immediate

      -- J: 000010
      when "000010" =>
        RegDst   <= '0';
        ALUSrc   <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';
        MemRead  <= '0';
        MemWrite <= '0';
        Branch   <= '0';
        ALUOp    <= "00";
        Jump     <= '1';
        SignZero <= '0';

      when others =>
        -- keep defaults
        null;
    end case;
  end process;
end architecture;