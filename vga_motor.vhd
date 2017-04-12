--------------------------------------------------------------------------------
-- VGA MOTOR
-- Anders Nilsson
-- 16-feb-2016
-- Version 1.1


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
  port ( clk			: in std_logic;
	 data			: in std_logic_vector(7 downto 0);
	 rst			: in std_logic;
	 vgaRed		        : out std_logic_vector(2 downto 0);
	 vgaGreen	        : out std_logic_vector(2 downto 0);
	 vgaBlue		: out std_logic_vector(2 downto 1);
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic);
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
		
  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data
  signal	tileAddr	: unsigned(10 downto 0);	-- Tile address

  signal        blank           : std_logic;                    -- blanking signal
	

  -- Tile memory type
  type ram_t is array (0 to 2047) of std_logic_vector(7 downto 0);

-- Tile memory
  signal tileMem : ram_t := (others => "00101100");
		  
begin

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else
	ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	
  -- Horizontal pixel counter

  process(clk)
  begin
    if rising_edge(clk) then
      if Clk25 = '1' then
        if  Xpixel = 800 then
          Xpixel <= "0000000000";
        else
          Xpixel <= Xpixel + "1";
        end if;
      end if;
    end if;
  end process;


  
  -- Horizontal sync

  process(clk)
  begin
    if rising_edge(clk) then
      if Clk25 = '1' then
        if  Xpixel > 656 and Xpixel < 752 then
          Hsync <= '0';
        else
          Hsync <= '1';
        end if;
      end if;
    end if;
  end process;
  

  
  -- Vertical pixel counter

  process(clk)
  begin
    if rising_edge(clk) then
      if Clk25 = '1' then
        if  Ypixel = 521 then
          Ypixel <= "0000000000";
        else
          if Xpixel = 800 then
            Ypixel <= Ypixel + "1";
          end if;
        end if;
      end if;
    end if;
  end process;

	

  -- Vertical sync

  process(clk)
  begin
    if rising_edge(clk) then
      if Clk25 = '1' then
        if  Ypixel > 490 and Ypixel < 492 then
          Vsync <= '0';
        else
          Vsync <= '1';
        end if;
      end if;
    end if;
    
  end process;



  
  -- Video blanking signal

  process(clk)
  begin
    if rising_edge(clk) then
      if Clk25 = '1' then
        if Xpixel > 640 or Ypixel > 480 then
          blank <= '1';
        else
          blank <= '0';
        end if;
      end if;
    end if;
  end process;
  


  
  -- Tile memory
  process(clk)
  begin
    if rising_edge(clk) then
      if (blank = '0') then
        --tilePixel <= tileMem(to_integer(tileAddr));
        tilePixel <= data;
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;
	


  -- Tile memory address composite
  tileAddr <= unsigned(data(4 downto 0)) & Ypixel(4 downto 2) & Xpixel(4 downto 2);


  -- Picture memory address composite
  --addr <= to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5);


  -- VGA generation
  vgaRed(2) 	<= tilePixel(7);
  vgaRed(1) 	<= tilePixel(6);
  vgaRed(0) 	<= tilePixel(5);
  vgaGreen(2)   <= tilePixel(4);
  vgaGreen(1)   <= tilePixel(3);
  vgaGreen(0)   <= tilePixel(2);
  vgaBlue(2) 	<= tilePixel(1);
  vgaBlue(1) 	<= tilePixel(0);


end Behavioral;

