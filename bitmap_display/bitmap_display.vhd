library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity bitmap_display is
  Port (
    clk   : in    STD_LOGIC;
    HSYNC : inout STD_LOGIC;
    VSYNC : inout STD_LOGIC;
    Red   : out   STD_LOGIC_VECTOR(3 downto 0);
    Green : out   STD_LOGIC_VECTOR(3 downto 0);
    Blue  : out   STD_LOGIC_VECTOR(3 downto 0)
  );
end bitmap_display;

architecture Behavioral of bitmap_display is
  signal hcounter : STD_LOGIC_VECTOR(9 downto 0);
  signal vcounter : STD_LOGIC_VECTOR(9 downto 0);
  signal vaddr    : STD_LOGIC_VECTOR(5 downto 0);
  signal vdata    : STD_LOGIC_VECTOR(63 downto 0);

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
    ADDRA : in  STD_LOGIC_VECTOR(5 downto 0);
    DOUTA : out STD_LOGIC_VECTOR(63 downto 0);
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
      -- need to update rom address early enough to ensure that the
      -- output is ready when it needs to be drawn
      if hcounter = ht_vis + ht_fp + ht_sync + ht_bp - 2 then
        if vcounter = vt_vis + vt_fp + vt_sync + vt_bp - 1 then
          vaddr <= (others => '0');
        else
          vaddr <= vaddr + 1;
        end if;
      end if;

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

  do_rgb: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if hcounter < ht_vis and vcounter < vt_vis then
        if vdata(to_integer(unsigned(63 - hcounter))) = '1' then
          Red(3 downto 0) <= "1111";
          Green(3 downto 0) <= "1111";
          Blue(3 downto 0) <= "1111";
        else
          Red(3 downto 0) <= "0000";
          Green(3 downto 0) <= "0000";
          Blue(3 downto 0) <= "0000";
        end if;
      else
        Red(3 downto 0) <= "0000";
        Green(3 downto 0) <= "0000";
        Blue(3 downto 0) <= "0000";
      end if;
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

end Behavioral;
