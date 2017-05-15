library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cpu_tb is
end cpu_tb;

architecture behavioral of cpu_tb is

  component cpu
    port (
    clk : in std_logic;
    vga_data : out std_logic_vector(7 downto 0);
    buttons : in std_logic_vector(4 downto 0);
    color : in std_logic_vector(7 downto 0)
    );
  end component;

  signal clk : std_logic;
  signal vga_data : std_logic_vector(7 downto 0);
  signal color : std_logic_vector(7 downto 0);
  signal buttons : std_logic_vector(4 downto 0);
begin  -- behavioral

  uut : cpu port map (
    clk => clk,
    vga_data => vga_data,
    color => color,
    buttons => buttons
    );

  clk <= not clk after 5 ns;

end behavioral;
