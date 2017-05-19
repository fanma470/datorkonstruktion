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

  type k1 is array (0 to 15) of std_logic_vector(7 downto 0);  -- k1
  type k2 is array (0 to 3) of std_logic_vector(7 downto 0);  -- k1
  signal upc : integer := 0;
  signal supc : integer;  -- suPC return adress ANVANDS EJ
  type um is array (0 to 31) of std_logic_vector(31 downto 0);  -- uMinne

  signal umem : um := (x"07c00000",     --00
                       x"04600000",     --01
                       x"00010000",     --02
                       x"03c08000",     --03
                       x"07e08000",     --04
                       x"03c00000",     --05
                       x"05c08000",     --06
                       x"12000000",     --07
                       x"4c000000",     --08
                       x"09c08000",     --09
                       x"05818000",     --0a
                       x"0c818000",     --0b
                       x"14000000",     --0c
                       x"4c000000",     --0d
                       x"09818000",     --0e
                       x"1c000000",     --0f
                       x"5402800e",     --10
                       x"14000000",     --11
                       x"6c02800e",     --12
                       x"02c18000",     --13
                       x"00040000",     --14
                       x"00028013",     --15
                       x"00040013",     --16
                       x"00018000",     --17
                       x"F0018000",     --18
                       x"0d418000",     --19
                       others => x"00000000");

    -- z n c o l
  signal op : std_logic_vector(3 downto 0);
  --signal grx : std_logic_vector(1 downto 0);
  signal m  : std_logic_vector(1 downto 0);
  signal address  : std_logic_vector(7 downto 0);

  --mappar till rätt operation
  signal op_mode : k1 := (x"0a", x"0b", x"0c", x"0f", x"11", x"13", x"14",
                          x"16", x"18", x"19", others => (others => '0'));
  --mappar till rätt addresseringsmod
  signal address_mode : k2 := (x"03", x"04", x"05", x"07");

  signal seq : std_logic_vector(3 downto 0);
  signal uaddr : std_logic_vector(14 downto 0);
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
  seq <= curr_umsig(18 downto 15);
  uaddr <= curr_umsig(14 downto 0);
  lc_inst <= curr_umsig(20 downto 19);

  
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
        when "0001" => upc <= to_integer(unsigned(op_mode(to_integer(unsigned(op)))));
        when "0010" => upc <= to_integer(unsigned(address_mode(to_integer(unsigned(m)))));
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
  
