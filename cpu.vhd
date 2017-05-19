library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cpu is
  port(
    -- in och utsignaler
    clk : in std_logic;
    vga_data : out std_logic_vector(7 downto 0);
    buttons : in std_logic_vector(4 downto 0);
    color : in std_logic_vector(7 downto 0)
  );
end cpu;

--TODO addreseringsmoder, uMinneprogrammering, hoppas att det funkar

architecture behavioral of cpu is
  -- intarna signaler
  type prog_mem is array (0 to 255) of std_logic_vector(15 downto 0);           --programminne
  signal asr : std_logic_vector(7 downto 0) := x"00";  -- ASR
  signal ir : std_logic_vector(15 downto 0) := x"0000";  -- Instruktionsregister
  signal pc : std_logic_vector(7 downto 0) := x"00";                             --program counter
  signal buss : std_logic_vector(15 downto 0) := x"0000";  -- buss
  
  --statusflaggor
  -- z n c o l
  signal sr : std_logic_vector(3 downto 0) := "0000";  --statusregister
  
 


  -- register o mux
  signal sel : std_logic_vector(1 downto 0) := "00";  -- Mux SEL
  type grx is array (0 to 3) of std_logic_vector(15 downto 0);  -- grX
  signal gmux : grx;
  
  -- ALU
  signal ar : std_logic_vector(15 downto 0) := x"0000";  -- Accumulatorregister
  signal helpr : std_logic_vector(15 downto 0) := x"0000";  -- help register


  signal umsig_cpu : std_logic_vector(31 downto 0);
  signal tobuss : std_logic_vector(2 downto 0);
  --load        0000
  --store       0001
  --add         0010
  --sub         0011
  --and         0100
  --bra         0101
  --bne         0110
  --beq         0111
  --btn         1000
  --vga         1001
  signal pm : prog_mem := ("0000000100000000",  --00 load, gr0, d40   INIT
                           "0000000000101000",  --01 d40
                           "0000010100000000",  --02 load gr1, d30
                           "0000000000011110",  --03 d30
                           "0000100100000000",  --04 load gr2 0
                           "0000000000000000",  --05
                           "0001100011111111",  --06 store gr2, pmFF
                           "1111000000000000",  --07 NOP
                           --MAIN LOOP
                           "0000110011111111",  --08 load gr3 pmFF
                           "0010110100000000",  --09 add gr3, 0
                           "0000000000000000",  --0A d0
                           "0110000000101011",  --0B bne btn_check <<<<<<<<<<<
                           --UPPKNAPP
                           "1000110000000000",  --0C btn gr3
                           "0100110100000001",  --0D and gr3, x0001
                           "0000000000000001",  --0E x0001
                           "0011110100000000",  --0F sub gr3 1
                           "0000000000000001",  --10 1
                           "0111000000110011",  --11 beq btn_up    <<<<<<<<<<<<
                           --NEDKNAPP
                           "1000110000000000",  --12 btn gr3
                           "0100110100000000",  --13 and gr3 x0004
                           "0000000000000100",  --14 x0004
                           "0011110100000000",  --15 sub gr3 04
                           "0000000000000100",  --16 04
                           "0111000000110011",  --17 beq btn_down <<<<<<<<<<<<<
                           --HOGERKNAPP
                           "1000110000000000",  --18 btn gr3
                           "0100110100000000",  --19 and gr3 x0008
                           "0000000000001000",  --1A x0004
                           "0011110100000000",  --1b sub gr3 08
                           "0000000000001000",  --1c 08
                           "0111000000110011",  --1d beq btn_right <<<<<<<<<<<<<
                           --LEFT
                           "1000110000000000",  --1e btn gr3
                           "0100110100000000",  --1f and gr3 x0002
                           "0000000000000010",  --20 x0002
                           "0011110100000000",  --21 sub gr3 02
                           "0000000000000010",  --22 02
                           "0111000000110011",  --23 beq btn_left <<<<<<<<<<<<<
                           --SELECT
                           "1000110000000000",  --24 btn gr3
                           "0100110100000000",  --25 and gr3 x0010
                           "0000000000010000",  --26 x0010
                           "0011110100000000",  --27 sub gr3 x10
                           "0000000000010000",  --28 x10
                           "0111000000110011",  --29 beq btn_sel <<<<<<<<<<<<<
                           --LOOP
                           "0101000000001000",  --2A bra main_loop <<<<<<<<<<
                           --BTN_CHECK
                           "1000110000000000",  --2B btn gr3
                           "0010110100000000",  --2C add gr3, 0
                           "0000000000000000",  --2D
                           "0110000000000111",  --2e bne main_loop <<<<<<<<<<<
                           "0000110100000000",  --2f load gr3, 0
                           "0000000000000000",  --30 0
                           "0001110011111111",  --31 store gr3 i pmFF
                           "0101000000001000",  --32 bra main_loop <<<<<<<<<
                           --BTN_UP
                           "0010010100000000",  --33 add gr1, 0
                           "0000000000000000",  --34 0
                           "0111000000000111",  --35 beq main_loop <<<<<<<<<<<
                           "0011010100000000",  --36 sub gr1 1
                           "0000000000000001",  --37 1
                           "0000110100000000",  --38 load gr3 x82
                           "0000000010000010",  --39 x82
                           "1001110000000000",  --3a vga gr3
                           "1001010000000000",  --3b vga gr1
                           "0000110100000000",  --3c load gr3 1
                           "1111111111111111",  --3d 1
                           "0001110011111111",  --3e store pmFF
                           "0101000000001000",  --3f bra main_loop <<<<<<<<<<<
                           
                           others => "0000000000000000");
  
  signal curr_pm : std_logic_vector(15 downto 0) := x"0000";

  signal testsignal : unsigned(7 downto 0) := x"00";
  signal Xsignal : unsigned(7 downto 0) := "00101000";

  signal check_c : std_logic_vector(16 downto 0);

  signal z : std_logic := '0';            -- z flagga
  signal n : std_logic := '0';            -- n flagga
  signal c : std_logic := '0';            -- c flagga
  signal o : std_logic := '0';            -- o flagga

  --VGA
  --signal vga_data : std_logic_vector(7 downto 0);

  component umem
    port (
      clk : in std_logic;               -- clock
      umsig : out std_logic_vector(31 downto 0);  -- umsig
      ir : in std_logic_vector(15 downto 0);
      sr : in std_logic_vector(3 downto 0)
      );
  end component;

begin

  --port map umem
  umemComp : umem port map (
    clk => clk,
    umsig => umsig_cpu,
    ir => ir,
    sr => sr
  );
  
  --umsig <= umem(to_integer(unsigned(upc)));
  tobuss <= umsig_cpu(27 downto 25);
  curr_pm <= pm(to_integer(unsigned(asr)));

  process(clk)
  begin
    if rising_edge(clk) then
      sel <= ir(11 downto 10);
    end if;
  end process;
  
  
  --till buss
  with tobuss select buss <=
    ir when "001",
    curr_pm when "010",
    x"00" & pc when "011",
    ar when "100",
    helpr when "101",
    gmux(to_integer(unsigned(sel))) when "110",
    x"0000" when others;


  
  -- IR
  process(clk)
  begin
    if rising_edge(clk) then
      if umsig_cpu(24 downto 22) = "001" then
        ir <= buss;
      end if;
    end if;             
  end process;

  --PM
  process(clk)
  begin
    if rising_edge(clk) then
      if umsig_cpu(24 downto 22) = "010" then
        pm(to_integer(unsigned(asr))) <= buss;
      end if;
    end if;             
  end process;

  -- PC
  process(clk)
  begin
    if rising_edge(clk) then
      if umsig_cpu(24 downto 22) = "011" then
        pc <= buss(7 downto 0);
      elsif umsig_cpu(21) = '1' then  --P bit
        pc <= std_logic_vector(unsigned(pc) + 1);
      end if;
    end if;
  end process;

  -- HR
  process(clk)
  begin
    if rising_edge(clk) then
      if umsig_cpu(24 downto 22) = "101" then
        vga_data <= buss(7 downto 0);
      end if;
    end if;                     
  end process;
  

  
  -- GRX
  process(clk)
  begin
    if rising_edge(clk) then
      if umsig_cpu(24 downto 22) = "110" then
        gmux(to_integer(unsigned(sel))) <= buss;
      elsif umsig_cpu(31 downto 28) = "1111" then
        gmux(to_integer(unsigned(sel))) <=  "00000000000" & buttons;
      end if;
    end if;             
  end process;
  

  -- ASR
  process(clk)
  begin
    if rising_edge(clk) then
      if umsig_cpu(24 downto 22) = "111" then
        asr <= buss(7 downto 0);
      end if;
    end if;             
  end process;

  --acc
  process(clk)
  begin
    if rising_edge(clk) then
      case umsig_cpu(31 downto 28) is
        when "0001" => ar <= buss;
        when "0010" => ar <= not buss;
        when "0011" => ar <= X"0000";
        when "0100" => ar <= std_logic_vector(signed(ar) + signed(buss));
        when "0101" => ar <= std_logic_vector(signed(ar) - signed(buss));
        --when "0110" => ar <= ar and buss;
        when "0110" => ar <= ar and buss;
        when "0111" => ar <= ar or buss;
        when others => null;
      end case;
    end if;
  end process;

  with umsig_cpu(31 downto 28) select c <=
    check_c(16) when "0101",
    '0' when others;

    --flaggor
  z <= sr(0);
  n <= sr(1);
  c <= sr(2);
  o <= sr(3);

    -- z n c o l
  process(clk)
    begin
    if rising_edge(clk) then
      if ar = x"0000" then
        sr <= sr or "0001";          -- z UNEQUAL LENGTH?
      else
        sr <= sr and "1110";
      end if;
      if umsig_cpu(31 downto 28) = "0100" then
        if signed(ar) + signed(buss) > 65535 then
          sr <= sr or "1000";        -- o
        else
          sr <= sr and "0111";
        end if;
      end if;
    end if;
  end process;
        
end behavioral;
