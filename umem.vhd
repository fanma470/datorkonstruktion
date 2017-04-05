library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity umem is
  port(
    -- in och utsignaler
    clk, rst : in std_logic;
    umsig : out std_logic_vector(31 downto 0);
    ir : in std_logic_vector(15 downto 0)
  );
end umem;

architecture behavioral of umem is

  type k1 is array (7 downto 0) of std_logic_vector(7 downto 0);  -- k1
  type k2 is array (7 downto 0) of std_logic_vector(7 downto 0);  -- k1
  signal upc : integer;
  signal supc : std_logic_vector(7 downto 0) := x"00";  -- suPC return adress
  type um is array (0 to 31) of std_logic_vector(31 downto 0);  -- uMinne

  signal umem : um := (others => x"00000000");

  signal op : std_logic_vector(3 downto 0);
  signal grx : std_logic_vector(1 downto 0);
  signal m  : std_logic_vector(1 downto 0);
  signal address  : std_logic_vector(7 downto 0);
  signal op_mode : k1;
  signal address_mode : k2;

  signal seq : std_logic_vector(3 downto 0);
  signal uaddr : std_logic_vector(13 downto 0);


begin
  --um
  umsig <= umem(upc);
  seq <= umsig(17 downto 14);
  uaddr <= umsig(13 downto 0);
  --ir
  op <= ir(15 downto 12);
  grx <= ir(11 downto 10);
  m <= ir(9 downto 8);
  address <= ir(7 downto 0);

  process(clk)
    if rising_edge(clk) then
      case seq is
        when "0000" => upc <= upc + 1;
        when "0001" => upc <= address_mode(integer(m));
        when "0010" => upc <= op_mode(op);
        when "0011" => upc <= 0;
        when "0100" => upc <= integer(uaddr) + 1;  --TODO oj vi måste hantera
                                                   --vilkorliga hopp
        when others => null;
      end case;
    end if;
  end process;
  
end behavioral;
  
