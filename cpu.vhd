library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cpu is
  port(
    -- in och utsignaler
    clk, rst : in std_logic
  );
end cpu;


architecture behavioral of cpu is
  -- intarna signaler
  type prog_mem is array (0 to 255) of std_logic_vector(15 downto 0);           --programminne
  type k1 is array (7 downto 0) of std_logic_vector(7 downto 0);  -- k1
  type k2 is array (7 downto 0) of std_logic_vector(7 downto 0);  -- k1
  signal upc : std_logic_vector(4 downto 0);  -- uPC
  signal supc : std_logic_vector(7 downto 0) := x"00";  -- suPC return adress
  type um is array (0 to 31) of std_logic_vector(31 downto 0);  -- uMinne
  signal asr : std_logic_vector(7 downto 0) := x"00";  -- ASR
  signal ir : std_logic_vector(15 downto 0) := x"0000";  -- Instruktionsregister
  signal pc : std_logic_vector(7 downto 0) := x"00";                             --program counter
  signal buss : std_logic_vector(15 downto 0) := x"0000";  -- buss
  
  --statusflaggor
  signal z : std_logic := '0';          -- zero
  signal n : std_logic := '0'; 
  signal c : std_logic := '0';
  signal o : std_logic := '0';          -- overflow
  signal l : std_logic := '0';          -- loop
  
  signal lc : std_logic_vector(7 downto 0) := x"00";  -- loop count


  -- register o& mux
  signal sel : std_logic_vector(1 downto 0) := "00";  -- Mux SEL
  type grx is array (0 to 3) of std_logic_vector(15 downto 0);  -- grX
  -- ALU
  signal ar : std_logic_vector(15 downto 0) := x"0000";  -- Accumulatorregister
  signal helpr : std_logic_vector(15 downto 0) := x"0000";  -- help register


  signal umsig : std_logic_vector(31 downto 0);
  signal tobuss : std_logic_vector(2 downto 0);
  signal umem : um;
  signal pm : prog_mem;
  signal gmux : grx;

  signal testsignal : std_logic_vector(7 downto 0) := x"00";
  
  -- komponenter

begin

  umsig <= umem(to_integer(unsigned(upc)));
  tobuss <= umsig(27 downto 25);
  
   
  
  --till buss
  with tobuss select buss <=
    ir when "001",
    pm(to_integer(unsigned(pc))) when "010",
    x"0000" or pc when "011",
    ar when "100",
    helpr when "101",
    gmux(to_integer(unsigned(sel))) when "110",
    x"0000" when others;


  
  -- IR
  process(clk)
  begin
    if rising_edge(clk) then
      if umem(to_integer(unsigned(upc)))(24 downto 22) = "001" then
        ir <= buss;
      end if;
    end if;             
  end process;

  --PM
  process(clk)
  begin
    if rising_edge(clk) then
      if umem(to_integer(unsigned(upc)))(24 downto 22) = "010" then
        pm(to_integer(unsigned(asr))) <= buss;
      end if;
    end if;             
  end process;

  -- PC
  process(clk)
  begin
    if rising_edge(clk) then
      if umem(to_integer(unsigned(upc)))(24 downto 22) = "011" then
        pc <= buss(7 downto 0);
      elsif umem(to_integer(unsigned(upc)))(21) = '1' then  --P bit
          pc <= std_logic_vector(unsigned(pc) + 1);
      end if;
    end if;
  end process;

  -- HR
  process(clk)
  begin
    if rising_edge(clk) then
      if umem(to_integer(unsigned(upc)))(24 downto 22) = "101" then
         helpr <= buss;
      end if;
    end if;             
  end process;

  -- GRX
  process(clk)
  begin
    if rising_edge(clk) then
      if umem(to_integer(unsigned(upc)))(24 downto 22) = "110" then
        gmux(to_integer(unsigned(sel))) <= buss;
      end if;
    end if;             
  end process;

  -- ASR
  process(clk)
  begin
    if rising_edge(clk) then
      if umem(to_integer(unsigned(upc)))(24 downto 22) = "111" then
        asr <= buss(7 downto 0);
      end if;
    end if;             
  end process;

  -- LC
  process(clk)
  begin
    if rising_edge(clk) then
      if umem(to_integer(unsigned(upc)))(24 downto 22) = "111" then
        lc <= buss(7 downto 0);
      end if;
    end if;             
  end process;

  --acc
  process(clk)
  begin
    if rising_edge(clk) then
      case umem(to_integer(unsigned(upc)))(31 downto 28) is
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
        


                       
--      with umem(to_integer(unsigned(upc)))(31 downto 28) select ar <=
--        buss when "0001",
  --      not buss when "0010",
--  --      0 when "0011",
      --  ar + buss when "0100",
  --      ar - buss when "0101",
--        ar and buss when "0110",
  --      ar or buss when "0111",
    --    ar + buss when "1000",
      --  ar * 2 when "1001",
--        ar / 2 when "1010",
  --      ar sll 1 when "1011",
    --    ar srl 1 when "1100",
      --  ar when others;
--    end if;
--  end process;

end behavioral;
