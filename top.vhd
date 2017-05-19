library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--TODO
--Hantera knapptryck
--sätta upp videominne
--se till att motorn kan hatera upplösningen
--knapptryck -> cpu som avbrott _> när umem hoppar till noll kolla
--avbrottsflagga -> specialrutin
--programmera uminne
--skriva assembler
--programmera "spel"


entity top is
  port(
    -- in och utsignaler
    clk, btns : in std_logic;
    vgaRed : out std_logic_vector(2 downto 0);
    vgaGreen : out std_logic_vector(2 downto 0);
    vgaBlue : out std_logic_vector(2 downto 1);
    Hsync : out std_logic;
    Vsync : out std_logic;
    sw : in std_logic_vector(7 downto 0);
    btnu, btnd, btnl, btnr : in std_logic
    );
end top;

architecture behavioral of top is

  -- signaler
  signal vga_data : std_logic_vector(7 downto 0) := x"00";
  signal buttons : std_logic_vector(4 downto 0) := "00000";
  -- komponenter

  component cpu
    port (
      clk : in std_logic;
      vga_data : out std_logic_vector(7 downto 0);
      buttons : in std_logic_vector(4 downto 0);
      color : in std_logic_vector(7 downto 0)
      );
  end component;

  component vga_motor
    port (
      clk : in std_logic;
      data : in std_logic_vector(7 downto 0);
      switches : in std_logic_vector(7 downto 0);
      vgaRed : out std_logic_vector(2 downto 0);
      vgaGreen : out std_logic_vector(2 downto 0);
      vgaBlue : out std_logic_vector(2 downto 1);
      Hsync : out std_logic;
      Vsync : out std_logic);
  end component;
  
begin
  buttons(0) <= not btnu;
  buttons(1) <= not btnl;
  buttons(2) <= not btnd;
  buttons(3) <= not btnr;
  buttons(4) <= not btns;
  
  --port map cpu
  cpuComp : cpu port map (
    clk => clk,
    vga_data => vga_data,
    buttons => buttons,
    color => sw
);
  

  --port map vga_motor
  vga_motorComp : vga_motor port map (
    clk => clk,
    data => vga_data,
    switches => sw,
    vgared => vgared,
    vgagreen => vgagreen,
    vgablue => vgablue,
    hsync => hsync,
    vsync => vsync
);

  

end behavioral;
