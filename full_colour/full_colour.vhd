library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity full_colour is
  Port (
    clk   : in    STD_LOGIC;
    HSYNC : inout STD_LOGIC;
    VSYNC : inout STD_LOGIC;
    Red   : out   STD_LOGIC_VECTOR(3 downto 0);
    Green : out   STD_LOGIC_VECTOR(3 downto 0);
    Blue  : out   STD_LOGIC_VECTOR(3 downto 0)
  );
end full_colour;

architecture Behavioral of full_colour is
  signal hcounter : STD_LOGIC_VECTOR(9 downto 0);
  signal vcounter : STD_LOGIC_VECTOR(9 downto 0);
  signal vaddr    : STD_LOGIC_VECTOR(11 downto 0);
  signal vdata    : STD_LOGIC_VECTOR(11 downto 0);
  
  signal hpos     : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
  signal hdir     : STD_LOGIC := '1';
  signal vpos     : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
  signal vdir     : STD_LOGIC := '1';

  signal clk_out1 : STD_LOGIC;

  constant ht_vis  : integer := 640;
  constant ht_fp   : integer := 16;
  constant ht_sync : integer := 96;
  constant ht_bp   : integer := 48;

  constant vt_vis  : integer := 480;
  constant vt_fp   : integer := 10;
  constant vt_sync : integer := 2;
  constant vt_bp   : integer := 33;

  COMPONENT bitmap IS
  PORT (
    ADDRA : in  STD_LOGIC_VECTOR(11 downto 0);
    DOUTA : out STD_LOGIC_VECTOR(11 downto 0);
    CLKA  : in  STD_LOGIC
  );
  end component;

  component clock_divider IS
  port(
    CLK_IN1  : in  STD_LOGIC;
    CLK_OUT1 : out STD_LOGIC
  );
  end component;

begin

  bm : bitmap
  port map(
    CLKA => clk_out1,
    ADDRA => vaddr,
    DOUTA => vdata
  );

  clock : clock_divider
  port map(
    CLK_IN1 => clk,
    CLK_OUT1 => clk_out1
  );

  do_hcounter: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if hcounter = ht_vis + ht_fp + ht_sync + ht_bp - 1 then
        hcounter <= (others => '0');
        if vcounter = vt_vis + vt_fp + vt_sync + vt_bp - 1 then
          vcounter <= (others => '0');
        else
          vcounter <= vcounter + 1;
        end if;
      else
        hcounter <= hcounter + 1;
      end if;
    end if;
  end process;

  do_load_data: process(clk_out1) 
  begin
    if rising_edge(clk_out1) then
      if vcounter >= vpos and vcounter < 64 + vpos then
        if hcounter >= hpos and hcounter < 64 + hpos then
          vaddr <= vaddr + 1;
        end if;
      else
        vaddr <= (others => '0');
      end if;
    end if;
  end process;

  do_rgb: process(hcounter, vcounter, vdata, hpos, vpos)
  begin
    if hcounter < ht_vis and vcounter < vt_vis then
      if hcounter >= hpos and hcounter < 64 + hpos and vcounter >= vpos and vcounter < 64 + vpos then
        Red(3 downto 0) <= vdata(11 downto 8);
        Green(3 downto 0) <= vdata(7 downto 4);
        Blue(3 downto 0) <= vdata(3 downto 0);
      else
        Red(3 downto 0) <= "1111";
        Green(3 downto 0) <= "1111";
        Blue(3 downto 0) <= "1111";
      end if;
    else
      Red(3 downto 0) <= "0000";
      Green(3 downto 0) <= "0000";
      Blue(3 downto 0) <= "0000";
    end if;
  end process;

  do_hsync: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if hcounter > ht_vis - 1 + ht_fp and hcounter < ht_vis + ht_fp + ht_sync then
        HSYNC <= '1';
      else
        HSYNC <= '0';
      end if;
    end if;
  end process;

  do_vsync: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if vcounter > vt_vis - 1 + vt_fp and vcounter < vt_vis + vt_fp + vt_sync then
        VSYNC <= '0';
      else
        VSYNC <= '1';
      end if;
    end if;
  end process;

  do_movement: process(VSYNC)
  begin
    if rising_edge(VSYNC) then
      if hdir = '1' then
        hpos <= hpos + 1;
      else
        hpos <= hpos - 1;
      end if;
      
      if vdir = '1' then
        vpos <= vpos + 1;
      else
        vpos <= vpos - 1;
      end if;
    end if;
  end process;

  do_bounds_check: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if hpos = ht_vis - 64 then
        hdir <= '0';
      elsif hpos = 0 then
        hdir <= '1';
      end if;
      
      if vpos = vt_vis - 64 then
        vdir <= '0';
      elsif vpos = 0 then
        vdir <= '1';
      end if;
    end if;
  end process;

end Behavioral;
