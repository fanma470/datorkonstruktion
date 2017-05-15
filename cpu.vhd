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
  signal pm : prog_mem := ("0000000000101000",  --lda gr0 d40 --sätt x i mitten
                           "0000010000011110",  --lda gr1 d30 --y i mitten
                           "0000100000000000",  --lda gr2 0   --stäng av pennan
                           "0001100011111111",  --store gr2 i pm(255)
                           --main loop test
                           "0000010010000001",  --lda gr1 x81
                           "1001010000000000",
                           "0000000000000000",  --lda gr0 d42
                           "0000000000000000",
                           "1001000000000000",
                           "0101000000000000",
                           others => (others => '0'));
  
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
  sel <= curr_pm(11 downto 10);
  
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
        gmux(to_integer(unsigned(sel))) <= buttons or x"0000";
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
