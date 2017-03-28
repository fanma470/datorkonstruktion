library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity CPU is
  port(
    -- in och utsignaler
  );
end CPU;


architecture behavioral of CPU is
  -- intärna signaler
  type prog_mem is array (0 to 255) of std_logic_vector(15 downto 0);           --programminne
  type k1 is array (7 downto 0) of std_logic_vector(7 downto 0);  -- k1
  type k2 is array (7 downto 0) of std_logic_vector(7 downto 0);  -- k1
  signal upc : std_logic_vector(7 downto 0) := 0x00;  -- uPC
  signal supc : std_logic_vector(7 downto 0) := 0x00;  -- suPC
  type um is array (31 downto 0) of std_logic_vector(31 downto 0);  -- uMinne
  signal asr : std_logic_vector(7 downto 0) := 0x00;  -- ASR
  signal ir : std_logic_vector(15 downto 0) := 0x00;  -- Instruktionsregister
  signal pc : std_logic_vector(7 downto 0) := 0x00;                             --program counter
  signal buss : std_logic_vector(15 downto 0) := 0x00;  -- buss
  
  --statusflaggor
  signal z : std_logic := '0';          -- zero
  signal n : std_logic := '0'; 
  signal c : std_logic := '0';
  signal o : std_logic := '0';          -- overflow
  signal l : std_logic := '0';          -- loop
  
  signal lc : std_logic_vector(7 donwto 0) := 0x00;  -- loop count


  -- register o& mux
  signal GR0 : std_logic_vector(15 downto 0) := 0x00;  -- GR0
  signal GR1 : std_logic_vector(15 downto 0) := 0x00;
  signal GR2 : std_logic_vector(15 downto 0) := 0x00;
  signal GR3 : std_logic_vector(15 downto 0) := 0x00;  -- GR3
  signal sel : std_logic_vector(1 downto 0) := 0x0;  -- Mux SEL

  -- ALU
  signal ar : std_logic_vector(15 downto 0) := 0x00;  -- Accumulatorregister

  
  -- komponenter

begin

  process(clk)
  begin
    if rising_edge(clk) then
      
    end if;


  end process;

end behavioral;
