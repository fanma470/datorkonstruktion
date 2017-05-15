library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity umem is
  port(
    -- in och utsignaler
    clk : in std_logic;
    umsig : out std_logic_vector(31 downto 0);
    ir : in std_logic_vector(15 downto 0);
    sr : in std_logic_vector(3 downto 0)
  );
end umem;

architecture behavioral of umem is

  type k1 is array (15 downto 0) of std_logic_vector(7 downto 0);  -- k1
  type k2 is array (3 downto 0) of std_logic_vector(7 downto 0);  -- k1
  signal upc : integer := 0;
  signal supc : integer;  -- suPC return adress ANVANDS EJ
  type um is array (0 to 31) of std_logic_vector(31 downto 0);  -- uMinne

  signal umem : um := (x"00f80000", x"008a0000", x"00001000", x"00780800",
                       x"00fa0800", x"00780000", x"00b80800", x"02400000",
                       x"09840000", x"01380800", x"00b01800", x"01901800",
                       x"02800000", x"09800000", x"01301800", x"03800000",
                       x"0a800000", x"01301800", x"02800000", x"0d800000",
                       x"01301800", x"03800000", x"00410000", x"1a008000",
                       x"01306000", x"00002970", x"00581800", x"000041c0",
                       x"00021800", x"005a1800", x"00007800", others => x"00000000");
  
    -- z n c o l
  signal op : std_logic_vector(3 downto 0);
  --signal grx : std_logic_vector(1 downto 0);
  signal m  : std_logic_vector(1 downto 0);
  signal address  : std_logic_vector(7 downto 0);

  --mappar till rätt operation
  signal op_mode : k1;
  --mappar till rätt addresseringsmod
  signal address_mode : k2;

  signal seq : std_logic_vector(3 downto 0);
  signal uaddr : std_logic_vector(13 downto 0);
  signal curr_umsig : std_logic_vector(31 downto 0);  -- internal umsig

  signal z : std_logic := '0';            -- z flagga
  signal n : std_logic := '0';            -- n flagga
  signal c : std_logic := '0';            -- c flagga
  signal o : std_logic := '0';            -- o flagga
  signal l : std_logic := '0';            -- l flagga

  signal lc : integer := 0;             -- ANVANDS EJ
  signal lc_inst : std_logic_vector(1 downto 0) := "00";  -- loop count instruction
  
begin
  --um
  umsig <= umem(upc);                   --skickas ut
  
  curr_umsig <= umem(upc);              --intern
  seq <= curr_umsig(17 downto 14);
  uaddr <= curr_umsig(13 downto 0);
  lc_inst <= curr_umsig(19 downto 18);

  
  --ir
  op <= ir(15 downto 12);
  --grx <= ir(11 downto 10);
  m <= ir(9 downto 8);
  address <= ir(7 downto 0);

  --flaggor
  z <= sr(0);
  n <= sr(1);
  c <= sr(2);
  o <= sr(3);

  with lc select l <=
    '0' when 0,
    '1' when others;
  
  
    -- LC
  process(clk)
  begin
    if rising_edge(clk) then
      case lc_inst is
        when "01" => lc <= lc - 1;
        when "10" => lc <= to_integer(unsigned(address));
        when "11" => lc <= to_integer(unsigned(uaddr));
        when others => null;
      end case;
    end if;             
  end process;

  --microminnesprocess
  process(clk)
    begin
    if rising_edge(clk) then
      case seq is
        when "0000" => upc <= upc + 1;
        when "0001" => upc <= to_integer(unsigned(address_mode(to_integer(unsigned(m)))));
        when "0010" => upc <= to_integer(unsigned(op_mode(to_integer(unsigned(op)))));
        when "0011" => upc <= 0;
        when "0100" =>
          if z = '1' then
            upc <= to_integer(unsigned(uaddr)) + 1;
          else
            upc <= upc + 1;
          end if;
        when "0101" => upc <= to_integer(unsigned(uaddr));
        when "0110" =>
          supc <= upc + 1;
          upc <= to_integer(unsigned(uaddr));
        when "0111" => upc <= supc;
        when "1000" =>
          if z = '1' then
            upc <= to_integer(unsigned(uaddr));
          else
            upc <= upc + 1;
          end if;
        when "1001"=>
          if n = '1' then
            upc <= to_integer(unsigned(uaddr));
          else
            upc <= upc + 1;
          end if;
        when "1100" =>
          if l = '1' then
            upc <= to_integer(unsigned(uaddr));
          else
            upc <= upc + 1;
          end if;
        when "1111" => upc <= 0;
        when others => null;
      end case;
    end if;
  end process;
  
end behavioral;
  
