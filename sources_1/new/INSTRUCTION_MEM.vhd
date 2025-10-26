library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity INSTRUCTION_MEM is 
port (
    address : in std_logic_vector(31 downto 0);
    instruction : out std_logic_vector(31 downto 0)
);
end INSTRUCTION_MEM;

architecture RTL of INSTRUCTION_MEM is
    -- 1024 x 32-bit memory
    type mem_type is array(0 to 1023) of std_logic_vector(31 downto 0);
    -- default init with some arguments
    signal instrmem : mem_type := ( 

  0  => "00111000000000010000000000000001",  -- xori  $1,$0,1        ; $1 = 1
  1  => "00111000000000100000000000000100",  -- xori  $2,$0,4        ; $2 = 4 (word stride)
  2  => "00111000000010000000000000100000",  -- xori  $8,$0,32       ; $8 = base addr 32
  3  => "00111000000010010000000000000000",  -- xori  $9,$0,0        ; $9 = fib(n-2) = 0
  4  => "00111000000010100000000000000001",  -- xori  $10,$0,1       ; $10 = fib(n-1) = 1
  5  => "00111000000011000000000000000000",  -- xori  $12,$0,0       ; $12 = counter = 0
  6  => "00111000000011010010011100010000",  -- xori  $13,$0,10      ; $13 = limit = 10000

-- LOOP:
  7  => "10101101000010010000000000000000",  -- sw    $9,0($8)        ; store fib(n-2)
  8  => "00000001001010100101100000100000",  -- add   $11,$9,$10      ; $11 = fib(n)
  9  => "00000001010000000100100000100000",  -- add   $9,$10,$0       ; shift: $9 = fib(n-1)
 10  => "00000001011000000101000000100000",  -- add   $10,$11,$0      ; shift: $10= fib(n)
 11  => "00000001000000100100000000100000",  -- add   $8,$8,$2        ; base += 4
 12  => "00000001100000010110000000100000",  -- add   $12,$12,$1      ; counter++
 13  => "00010101100011011111111111111001",  -- bne   $12,$13,LOOP    ; branch back to 7

-- EXIT:
 14  => "00001000000000000000000000010000",  -- j     16              ; jump to END
 15  => "00111000000000000000000000000000",  -- xori  $0,$0,0         ; safe filler
-- END:
 16  => "10101100000000000000000000000000",  -- sw    $0,0($0)        ; harmless


---- easy unbounded fib 
--  0  => "00111000000000010000000000000001",  -- xori  $1,$0,1        ; $1 = 1
--  1  => "00111000000000100000000000000100",  -- xori  $2,$0,4        ; $2 = 4 (word stride)
--  2  => "00111000000010000000000000000000",  -- xori  $8,$0,0        ; $8 = fib(n-2) = 0
--  3  => "00111000000010010000000000000001",  -- xori  $9,$0,1        ; $9 = fib(n-1) = 1
--  4  => "00111000000011000000000000100000",  -- xori  $12,$0,32       ; $12 = base addr (0x20)

---- LOOP:
--  5  => "10101101100010000000000000000000",  -- sw    $8,0($12)        ; store fib
--  6  => "00000001000010010101100000100000",  -- add   $11,$8,$9        ; next = a+b
--  7  => "00000001001000000100000000100000",  -- add   $8,$9,$0         ; a = b
--  8  => "00000001011000000100100000100000",  -- add   $9,$11,$0        ; b = next
--  9  => "00000001100000100110000000100000",  -- add   $12,$12,$2       ; base += 4
-- 10  => "00001000000000000000000000000101",  -- j     5                ; jump to LOOP
-- 11  => "00000000000000000000000000000000",  -- nop


        others => (others => '0')
    );
    signal temp     : std_logic_vector(31 downto 0);

begin
    
    instruction <= temp;
    
    process(address)
        variable addr_idx : integer;
    begin
        addr_idx := to_integer(unsigned(address(31 downto 2))); -- divide by 4
        if addr_idx >= 0 and addr_idx <= 1023 then
            temp <= instrmem(addr_idx);
        else
            temp <= (others => '0'); -- NOP instruction
        end if;

    end process;
    


end RTL;