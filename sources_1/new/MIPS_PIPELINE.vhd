library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPSpipeline is
  port (
    clk   : in  std_logic;
    btnC : in  std_logic; -- reset
    led : out std_logic_vector(15 downto 0);
    fib_num : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of MIPSpipeline is
  --------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------
  -- 32-bit constant 4 for PC+4
  constant FOUR : std_logic_vector(31 downto 0) :=
    (31 downto 3 => '0', 2 => '1', 1 => '0', 0 => '0');

  --------------------------------------------------------------------
  -- PC / IF signals
  --------------------------------------------------------------------
  signal PC, PCin         : std_logic_vector(31 downto 0);
  signal PC4              : std_logic_vector(31 downto 0);
  signal Instruction      : std_logic_vector(31 downto 0);

  -- IF/ID pipeline
  signal ID_PC4           : std_logic_vector(31 downto 0);
  signal ID_Instruction   : std_logic_vector(31 downto 0);
  signal IFID_flush       : std_logic := '0';
  signal IFID_WriteEn     : std_logic := '1'; -- give these default values
  signal PC_WriteEn       : std_logic := '1';

  --------------------------------------------------------------------
  -- ID signals
  --------------------------------------------------------------------
  signal Opcode, f_Function : std_logic_vector(5 downto 0); 
  signal rs, rt, rd       : std_logic_vector(4 downto 0);
  signal imm16            : std_logic_vector(15 downto 0);

  -- Regfile read / WB-forwarded read
  signal ReadData1, ReadData2      : std_logic_vector(31 downto 0);
  signal ReadData1Out, ReadData2Out: std_logic_vector(31 downto 0);

  -- Immediate extension
  signal sign_ext_out, zero_ext_out: std_logic_vector(31 downto 0);
  signal Im16_Ext                  : std_logic_vector(31 downto 0);

  -- Main control (raw from ID)
  signal RegDst, ALUSrc, MemtoReg, RegWrite : std_logic := '0';
  signal MemRead, MemWrite, Branch, Jump    : std_logic := '0';
  signal SignZero, JRControl                : std_logic := '0';
  signal ALUOp                              : std_logic_vector(1 downto 0) := "00";

  -- Flush combine
  signal ID_flush, IF_flush, Stall_flush, flush : std_logic := '0';
  signal JumpControl, JumpFlush, notIFID_flush  : std_logic := '0';

  --------------------------------------------------------------------
  -- ID/EX pipeline
  --------------------------------------------------------------------
  signal EX_PC4           : std_logic_vector(31 downto 0);
  signal EX_Instruction   : std_logic_vector(31 downto 0);
  signal EX_ReadData1     : std_logic_vector(31 downto 0);
  signal EX_ReadData2     : std_logic_vector(31 downto 0);
  signal EX_Im16_Ext      : std_logic_vector(31 downto 0);
  signal EX_rs, EX_rt, EX_rd : std_logic_vector(4 downto 0);

  -- Masked ID controls latched into EX
  signal ID_RegDst, ID_ALUSrc, ID_MemtoReg, ID_RegWrite : std_logic;
  signal ID_MemRead, ID_MemWrite, ID_Branch, ID_JRControl: std_logic;
  signal ID_ALUOp        : std_logic_vector(1 downto 0);

  signal EX_RegDst, EX_ALUSrc, EX_MemtoReg, EX_RegWrite : std_logic;
  signal EX_MemRead, EX_MemWrite, EX_Branch, EX_JRControl: std_logic := '0';
  signal EX_ALUOp        : std_logic_vector(1 downto 0);

  --------------------------------------------------------------------
  -- EX stage: forwarding / ALU
  --------------------------------------------------------------------
  signal ForwardA, ForwardB  : std_logic_vector(1 downto 0);
  signal Bus_A_ALU           : std_logic_vector(31 downto 0);
  signal Bus_B_forwarded     : std_logic_vector(31 downto 0);
  signal Bus_B_ALU           : std_logic_vector(31 downto 0);
  signal ALUControl          : std_logic_vector(1 downto 0);
  signal EX_ALUResult        : std_logic_vector(31 downto 0);
  signal ZeroFlag, OverflowFlag, CarryFlag, NegativeFlag : std_logic := '0';

  signal EX_WriteRegister    : std_logic_vector(4 downto 0);

  -- Branch/J/JR PC control
  signal shiftleft2_bne_out  : std_logic_vector(31 downto 0);
  signal shiftleft2_jump_out : std_logic_vector(31 downto 0);
  signal jump_shift_in       : std_logic_vector(31 downto 0);
  signal PCbne, PC4bne       : std_logic_vector(31 downto 0);
  signal notZeroFlag         : std_logic := '0';
  signal bneControl, notbneControl : std_logic := '0';
  signal PCj, PC4bnej, PCjr  : std_logic_vector(31 downto 0);

  --------------------------------------------------------------------
  -- EX/MEM pipeline + MEM stage
  --------------------------------------------------------------------
  signal MEM_ALUResult       : std_logic_vector(31 downto 0);
  signal WriteDataOfMem      : std_logic_vector(31 downto 0);
  signal MEM_MemtoReg, MEM_RegWrite, MEM_MemRead, MEM_MemWrite : std_logic;
  signal MEM_WriteRegister   : std_logic_vector(4 downto 0);
  signal MEM_ReadDataOfMem   : std_logic_vector(31 downto 0);

  --------------------------------------------------------------------
  -- MEM/WB pipeline + WB stage
  --------------------------------------------------------------------
  signal WB_ReadDataOfMem    : std_logic_vector(31 downto 0);
  signal WB_ALUResult        : std_logic_vector(31 downto 0);
  signal WB_MemtoReg, WB_RegWrite : std_logic;
  signal WB_WriteRegister    : std_logic_vector(4 downto 0);
  signal WB_WriteData        : std_logic_vector(31 downto 0);
  
  
  signal reset : std_logic;
  signal pc_started : std_logic := '0'; -- pc started 
  

begin

reset <= btnC; -- active high 
led <= MEM_ALUResult(15 downto 0); -- temp output, selected bcs easy -- MEM_ALUResult
  --------------------------------------------------------------------
  -- ===== IF STAGE =====
  --------------------------------------------------------------------
  
  PC_Reg : entity work.REG_32b
    port map (RegOut => PC, RegIn => PCin, WriteEn => PC_WriteEn, reset => reset, clk => clk);
    
    -- port map (Q => PC, D => PCin, WriteEn => PC_WriteEn, reset => reset, clk => clk);


  -- PC + 4
  Add1 : entity work.Add
    port map (S => PC4, A => PC, B => FOUR); -- S

  -- Instruction memory
  InstructionMem1 : entity work.INSTRUCTION_MEM
    port map (Instruction => Instruction, Address => PC);

  -- IF/ID pipeline registers
  IFID_PC4 : entity work.REG_32b
    port map (RegOut => ID_PC4, RegIn => PC4, WriteEn => IFID_WriteEn, reset => reset, clk => clk);

  IFID_Instruction : entity work.REG_32b
    port map (RegOut => ID_Instruction, RegIn => Instruction, WriteEn => IFID_WriteEn, reset => reset, clk => clk);

  -- Delay IF_flush one cycle (so it arrives with the instr now in ID)
  IF_flush_bit : entity work.REG_1b
    port map (BitOut => IFID_flush, BitData => IF_flush, WriteEn => IFID_WriteEn, reset => reset, clk => clk);

  --------------------------------------------------------------------
  -- ===== ID STAGE =====
  --------------------------------------------------------------------
  -- Field decode
  Opcode   <= ID_Instruction(31 downto 26);
  f_Function <= ID_Instruction(5  downto 0);
  rs       <= ID_Instruction(25 downto 21);
  rt       <= ID_Instruction(20 downto 16);
  rd       <= ID_Instruction(15 downto 11);
  imm16    <= ID_Instruction(15 downto 0);

  -- Main control (combinational)
  MainControl : entity work.Control
    port map (
      RegDst   => RegDst,    ALUSrc   => ALUSrc,   MemtoReg => MemtoReg, RegWrite => RegWrite,
      MemRead  => MemRead,   MemWrite => MemWrite, Branch   => Branch,   ALUOp    => ALUOp,
      Jump     => Jump,      SignZero => SignZero, Opcode   => Opcode
    );

  -- Register file (WB connects here)
  Register_File : entity work.REG_FILE
    port map (
      ReadData1 => ReadData1,
      ReadData2 => ReadData2,
      WriteData => WB_WriteData,
      ReadReg1  => rs,
      ReadReg2  => rt,
      WriteReg  => WB_WriteRegister,
      RegWrite  => WB_RegWrite,
      reset     => reset,
      clk       => clk,
      fib_num   => fib_num
    );

  -- WB-stage read-during-write fix (override regfile reads when needed)
  WB_forward_block : entity work.WB_forward
    port map (
      ReadData1Out  => ReadData1Out,
      ReadData2Out  => ReadData2Out,
      ReadData1     => ReadData1,
      ReadData2     => ReadData2,
      rs            => rs,
      rt            => rt,
      WriteRegister => WB_WriteRegister,
      WriteData     => WB_WriteData,
      RegWrite      => WB_RegWrite
    );

  -- Sign/zero extend and select
  sign_extend1 : entity work.sign_extend
    port map (sign_ext_out => sign_ext_out, sign_ext_in => imm16);

  zero_extend1 : entity work.zero_extend
    port map (zero_ext_out => zero_ext_out, zero_ext_in => imm16);

  muxSignZero : entity work.mux2x32to32
    port map (DataOut => Im16_Ext, Data0 => sign_ext_out, Data1 => zero_ext_out, Sel => SignZero);

  -- JR detection (R-type funct=001000)
  JRControl_Block1 : entity work.JRControl_Block
    port map (JRControl => JRControl, ALUOp => ALUOp, JR_Function => f_Function);

  -- Determine which stages to flush when redirecting PC if needed 
  Discard_Instr_Block : entity work.Discard_Instr
    port map (ID_flush => ID_flush, IF_flush => IF_flush, jump => JumpControl, bne => bneControl, jr => EX_JRControl);

  -- Merge all flush/bubble sources (NOP)
  flush <= ID_flush or IFID_flush or Stall_flush;

  -- Mask ID control bundle on flush (turn instruction into a bubble) if needed 
  flush_block1 : entity work.flush_block
    port map (
      ID_RegDst    => ID_RegDst,    ID_ALUSrc    => ID_ALUSrc,    ID_MemtoReg => ID_MemtoReg,
      ID_RegWrite  => ID_RegWrite,  ID_MemRead   => ID_MemRead,   ID_MemWrite => ID_MemWrite,
      ID_Branch    => ID_Branch,    ID_ALUOp     => ID_ALUOp,     ID_JRControl => ID_JRControl,
      flush        => flush,
      RegDst       => RegDst,       ALUSrc       => ALUSrc,       MemtoReg    => MemtoReg,
      RegWrite     => RegWrite,     MemRead      => MemRead,      MemWrite    => MemWrite,
      Branch       => Branch,       ALUOp        => ALUOp,        JRControl   => JRControl
    );

  --------------------------------------------------------------------
  -- ===== ID/EX PIPELINE =====
  --------------------------------------------------------------------
  IDEX_PC4 : entity work.REG_32b
    port map (RegOut => EX_PC4, RegIn => ID_PC4, WriteEn => '1', reset => reset, clk => clk);

  IDEX_ReadData1 : entity work.REG_32b
    port map (RegOut => EX_ReadData1, RegIn => ReadData1Out, WriteEn => '1', reset => reset, clk => clk);

  IDEX_ReadData2 : entity work.REG_32b
    port map (RegOut => EX_ReadData2, RegIn => ReadData2Out, WriteEn => '1', reset => reset, clk => clk);

  IDEX_Im16_Ext : entity work.REG_32b
    port map (RegOut => EX_Im16_Ext, RegIn => Im16_Ext, WriteEn => '1', reset => reset, clk => clk);

  -- Carry the entire instruction for EX funct/rs/rt/rd extraction
  IDEX_rs_rt_rd : entity work.REG_32b
    port map (RegOut => EX_Instruction, RegIn => ID_Instruction, WriteEn => '1', reset => reset, clk => clk);

  EX_rs <= EX_Instruction(25 downto 21);
  EX_rt <= EX_Instruction(20 downto 16);
  EX_rd <= EX_Instruction(15 downto 11);

  -- Control bits through ID/EX (one-bit pipeline regs)
  IDEX_RegDst    : entity work.REG_1b port map (BitOut => EX_RegDst,    BitData => ID_RegDst,    WriteEn => '1', reset => reset, clk => clk);
  IDEX_ALUSrc    : entity work.REG_1b port map (BitOut => EX_ALUSrc,    BitData => ID_ALUSrc,    WriteEn => '1', reset => reset, clk => clk);
  IDEX_MemtoReg  : entity work.REG_1b port map (BitOut => EX_MemtoReg,  BitData => ID_MemtoReg,  WriteEn => '1', reset => reset, clk => clk);
  IDEX_RegWrite  : entity work.REG_1b port map (BitOut => EX_RegWrite,  BitData => ID_RegWrite,  WriteEn => '1', reset => reset, clk => clk);
  IDEX_MemRead   : entity work.REG_1b port map (BitOut => EX_MemRead,   BitData => ID_MemRead,   WriteEn => '1', reset => reset, clk => clk);
  IDEX_MemWrite  : entity work.REG_1b port map (BitOut => EX_MemWrite,  BitData => ID_MemWrite,  WriteEn => '1', reset => reset, clk => clk);
  IDEX_Branch    : entity work.REG_1b port map (BitOut => EX_Branch,    BitData => ID_Branch,    WriteEn => '1', reset => reset, clk => clk);
  IDEX_JRControl : entity work.REG_1b port map (BitOut => EX_JRControl, BitData => ID_JRControl, WriteEn => '1', reset => reset, clk => clk);
  IDEX_ALUOp1    : entity work.REG_1b port map (BitOut => EX_ALUOp(1),  BitData => ID_ALUOp(1),  WriteEn => '1', reset => reset, clk => clk);
  IDEX_ALUOp0    : entity work.REG_1b port map (BitOut => EX_ALUOp(0),  BitData => ID_ALUOp(0),  WriteEn => '1', reset => reset, clk => clk);

  --------------------------------------------------------------------
  -- ===== EX STAGE =====
  --------------------------------------------------------------------
  -- Forwarding decisions (compare EX_rs/rt with MEM/WB destinations)
  Forwarding_Block : entity work.ForwardingUnit
    port map (
      ForwardA          => ForwardA,
      ForwardB          => ForwardB,
      MEM_RegWrite      => MEM_RegWrite,
      WB_RegWrite       => WB_RegWrite,
      MEM_WriteRegister => MEM_WriteRegister,
      WB_WriteRegister  => WB_WriteRegister,
      EX_rs             => EX_rs,
      EX_rt             => EX_rt
    );

  -- 3-way muxes for ALU inputs: {ID/EX, MEM, WB}
  mux3A : entity work.mux3x32to32
    port map (DataOut => Bus_A_ALU, A => EX_ReadData1, B => MEM_ALUResult, C => WB_WriteData, mux32_select => ForwardA);

  mux3B : entity work.mux3x32to32
    port map (DataOut => Bus_B_forwarded, A => EX_ReadData2, B => MEM_ALUResult, C => WB_WriteData, mux32_select => ForwardB);

  -- ALUSrc mux (register vs immediate) AFTER forwarding
  muxALUSrc : entity work.mux2x32to32
    port map (DataOut => Bus_B_ALU, Data0 => Bus_B_forwarded, Data1 => EX_Im16_Ext, Sel => EX_ALUSrc);

  -- ALU control (recommended: use funct from instruction carried into EX)
  ALUControl_Block1 : entity work.ALUControl_Block
    port map (ALUControl => ALUControl, ALUOp => EX_ALUOp, ALU_Function => EX_Instruction(5 downto 0));
    -- If you want to mirror the original Verilog exactly, replace the line above with:
    -- port map (..., Function => EX_Im16_Ext(5 downto 0));

  -- ALU proper
  alu_block : entity work.ALU
    port map (
      Output   => EX_ALUResult,
      CarryOut    => CarryFlag,
      Zero     => ZeroFlag,
      Overflow => OverflowFlag,
      Negative => NegativeFlag,
      BussA        => Bus_A_ALU,
      BussB        => Bus_B_ALU,
      ALUControl  => ALUControl
    );

  -- Destination register select (R-type rd vs I-type rt)
  muxRegDst : entity work.mux2x5to5
    port map (addrOut => EX_WriteRegister, addr0 => EX_rt, addr1 => EX_rd, m_select => EX_RegDst);

  --------------------------------------------------------------------
  -- ===== BRANCH / J / JR PC CONTROL =====
  --------------------------------------------------------------------
  -- BNE: PC target = EX_PC4 + (signext(imm)<<2)
  shiftleft2_bne : entity work.shift_left_2
    port map (sl_out32 => shiftleft2_bne_out, sl_in32 => EX_Im16_Ext);

  Add_bne : entity work.Add
    port map (S => PCbne, A => EX_PC4, B => shiftleft2_bne_out);

  notZeroFlag   <= not ZeroFlag;
  bneControl    <= EX_Branch and notZeroFlag;

  muxbneControl : entity work.mux2x32to32
    port map (DataOut => PC4bne, Data0 => PC4, Data1 => PCbne, Sel => bneControl);

  -- Jump (ID stage): form absolute target {ID_PC4[31:28], (instr[25:0]<<2)}
  -- build input for sll 
  jump_shift_in <= "000000" & ID_Instruction(25 downto 0);
  
  shiftleft2_jump : entity work.shift_left_2
    port map (sl_out32 => shiftleft2_jump_out, sl_in32 => jump_shift_in);

  PCj <= ID_PC4(31 downto 28) & shiftleft2_jump_out(27 downto 0);

  notIFID_flush <= not IFID_flush;
  JumpFlush     <= Jump and notIFID_flush;     -- don't double-flush
  notbneControl <= not bneControl;
  JumpControl   <= JumpFlush and notbneControl; -- if BNE taken later, let it win

  muxJump : entity work.mux2x32to32
    port map (DataOut => PC4bnej, Data0 => PC4bne, Data1 => PCj, Sel => JumpControl);

  -- JR (EX stage): PC := rs
  PCjr <= Bus_A_ALU;

  muxJR : entity work.mux2x32to32
    port map (DataOut => PCin, Data0 => PC4bnej, Data1 => PCjr, Sel => EX_JRControl);

  --------------------------------------------------------------------
  -- ===== EX/MEM PIPELINE =====
  --------------------------------------------------------------------
  EXMEM_ALUResult : entity work.REG_32b
    port map (RegOut => MEM_ALUResult, RegIn => EX_ALUResult, WriteEn => '1', reset => reset, clk => clk);

  EXMEM_WriteDataOfMem : entity work.REG_32b
    port map (RegOut => WriteDataOfMem, RegIn => Bus_B_forwarded, WriteEn => '1', reset => reset, clk => clk);

  EXMEM_MemtoReg : entity work.Reg_1b port map (BitOut => MEM_MemtoReg, BitData => EX_MemtoReg, WriteEn => '1', reset => reset, clk => clk);
  EXMEM_RegWrite : entity work.Reg_1b port map (BitOut => MEM_RegWrite, BitData => EX_RegWrite, WriteEn => '1', reset => reset, clk => clk);
  EXMEM_MemRead  : entity work.Reg_1b port map (BitOut => MEM_MemRead,  BitData => EX_MemRead,  WriteEn => '1', reset => reset, clk => clk);
  EXMEM_MemWrite : entity work.Reg_1b port map (BitOut => MEM_MemWrite, BitData => EX_MemWrite, WriteEn => '1', reset => reset, clk => clk);

  EXMEM_WriteRegister4 : entity work.Reg_1b port map (BitOut => MEM_WriteRegister(4), BitData => EX_WriteRegister(4), WriteEn => '1', reset => reset, clk => clk);
  EXMEM_WriteRegister3 : entity work.Reg_1b port map (BitOut => MEM_WriteRegister(3), BitData => EX_WriteRegister(3), WriteEn => '1', reset => reset, clk => clk);
  EXMEM_WriteRegister2 : entity work.Reg_1b port map (BitOut => MEM_WriteRegister(2), BitData => EX_WriteRegister(2), WriteEn => '1', reset => reset, clk => clk);
  EXMEM_WriteRegister1 : entity work.Reg_1b port map (BitOut => MEM_WriteRegister(1), BitData => EX_WriteRegister(1), WriteEn => '1', reset => reset, clk => clk);
  EXMEM_WriteRegister0 : entity work.Reg_1b port map (BitOut => MEM_WriteRegister(0), BitData => EX_WriteRegister(0), WriteEn => '1', reset => reset, clk => clk);

  --------------------------------------------------------------------
  -- ===== MEM STAGE =====
  --------------------------------------------------------------------
  dataMem1 : entity work.dataMem
    port map (
      data   => MEM_ReadDataOfMem,    -- load data out
      address    => MEM_ALUResult,        -- byte/word addressing per your mem
      writeData  => WriteDataOfMem,       -- store data in
      writeenable   => MEM_MemWrite,         -- store enable
      MemRead    => MEM_MemRead,          -- load enable
      clk        => clk
    );

  --------------------------------------------------------------------
  -- ===== MEM/WB PIPELINE =====
  --------------------------------------------------------------------
  MEMWB_ReadDataOfMem : entity work.REG_32b
    port map (RegOut => WB_ReadDataOfMem, RegIn => MEM_ReadDataOfMem, WriteEn => '1', reset => reset, clk => clk);

  MEMWB_ALUResult : entity work.REG_32b
    port map (RegOut => WB_ALUResult, RegIn => MEM_ALUResult, WriteEn => '1', reset => reset, clk => clk);

  MEMWB_WriteRegister4 : entity work.Reg_1b port map (BitOut => WB_WriteRegister(4), BitData => MEM_WriteRegister(4), WriteEn => '1', reset => reset, clk => clk);
  MEMWB_WriteRegister3 : entity work.Reg_1b port map (BitOut => WB_WriteRegister(3), BitData => MEM_WriteRegister(3), WriteEn => '1', reset => reset, clk => clk);
  MEMWB_WriteRegister2 : entity work.Reg_1b port map (BitOut => WB_WriteRegister(2), BitData => MEM_WriteRegister(2), WriteEn => '1', reset => reset, clk => clk);
  MEMWB_WriteRegister1 : entity work.Reg_1b port map (BitOut => WB_WriteRegister(1), BitData => MEM_WriteRegister(1), WriteEn => '1', reset => reset, clk => clk);
  MEMWB_WriteRegister0 : entity work.Reg_1b port map (BitOut => WB_WriteRegister(0), BitData => MEM_WriteRegister(0), WriteEn => '1', reset => reset, clk => clk);

  MEMWB_MemtoReg : entity work.Reg_1b port map (BitOut => WB_MemtoReg, BitData => MEM_MemtoReg, WriteEn => '1', reset => reset, clk => clk);
  MEMWB_RegWrite : entity work.Reg_1b port map (BitOut => WB_RegWrite, BitData => MEM_RegWrite, WriteEn => '1', reset => reset, clk => clk);

  -- Writeback data select (ALU vs memory)
  muxMemtoReg : entity work.mux2x32to32
    port map (DataOut => WB_WriteData, Data0 => WB_ALUResult, Data1 => WB_ReadDataOfMem, Sel => WB_MemtoReg);

  --------------------------------------------------------------------
  -- ===== STALL CONTROL (load-use interlock) =====
  --------------------------------------------------------------------
  StallControl_block : entity work.StallControl
    port map (
      PC_WriteEn   => PC_WriteEn,
      IFID_WriteEn => IFID_WriteEn,
      Stall_flush  => Stall_flush,
      EX_MemRead   => EX_MemRead,
      EX_rt        => EX_rt,
      ID_rs        => rs,
      ID_rt        => rt,
      ID_Op        => Opcode
    );

end architecture;