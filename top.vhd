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
    clk, rst : in std_logic;
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
  signal vga_data : std_logic_vector(7 downto 0);
  signal buttons : std_logic_vector(3 downto 0);
  -- komponenter

  component cpu
    port (
      clk : in std_logic;
      rst : in std_logic;
      vga_data : out std_logic_vector(7 downto 0);
      buttons : in std_logic_vector(3 downto 0);
      color : in std_logic_vector(7 downto 0)
      );
  end component;

  component vga_motor
    port (
      clk : in std_logic;
      rst : in std_logic;
      data : in std_logic_vector(7 downto 0);
      vgaRed : out std_logic_vector(2 downto 0);
      vgaGreen : out std_logic_vector(2 downto 0);
      vgaBlue : out std_logic_vector(2 downto 1);
      Hsync : out std_logic;
      Vsync : out std_logic);
  end component;
  
begin
  buttons(0) <= btnu;
  buttons(1) <= btnl;
  buttons(2) <= btnd;
  buttons(3) <= btnr;
  
  --port map cpu
  cpuComp : cpu port map (
    clk => clk,
    rst => rst,
    vga_data => vga_data,
    buttons => buttons,
    color => sw
);
  

  --port map vga_motor
  vga_motorComp : vga_motor port map (
    clk => clk,
    rst => rst,
    --data => vga_data,
    data => sw,
    vgared => vgared,
    vgagreen => vgagreen,
    vgablue => vgablue,
    hsync => hsync,
    vsync => vsync
);

  

end behavioral;
