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
  signal hcounter : STD_LOGIC_VECTOR(11 downto 0);
  signal vcounter : STD_LOGIC_VECTOR(11 downto 0);

  signal vaddr1   : STD_LOGIC_VECTOR(11 downto 0);
  signal vdata1   : STD_LOGIC_VECTOR(11 downto 0);

  signal hpos1    : STD_LOGIC_VECTOR(9 downto 0) := "0000000100";
  signal hdir1    : STD_LOGIC;
  signal vpos1    : STD_LOGIC_VECTOR(9 downto 0) := "0000000100";
  signal vdir1    : STD_LOGIC;

  signal vaddr2   : STD_LOGIC_VECTOR(11 downto 0);
  signal vdata2   : STD_LOGIC_VECTOR(11 downto 0);

  signal hpos2    : STD_LOGIC_VECTOR(9 downto 0) := "0000100100";
  signal hdir2    : STD_LOGIC;
  signal vpos2    : STD_LOGIC_VECTOR(9 downto 0) := "0010110100";
  signal vdir2    : STD_LOGIC;

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
    CLKA  : IN STD_LOGIC;
    ADDRA : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    DOUTA : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    CLKB  : IN STD_LOGIC;
    ADDRB : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    DOUTB : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
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
    ADDRA => vaddr1,
    DOUTA => vdata1,
    CLKB => clk_out1,
    ADDRB => vaddr2,
    DOUTB => vdata2
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

  do_load_data: process(hcounter, vcounter, vpos1, vpos2, hpos1, hpos2)
  begin
    vaddr1 <= hcounter - hpos1 + 1 + std_logic_vector(shift_left(unsigned(vcounter - vpos1), 6));
    vaddr2 <= hcounter - hpos2 + 1 + std_logic_vector(shift_left(unsigned(vcounter - vpos2), 6));
  end process;

  do_rgb: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if hcounter < ht_vis and vcounter < vt_vis then
        if hcounter >= hpos1 and hcounter < 64 + hpos1 and vcounter >= vpos1 and vcounter < 64 + vpos1 then
          Red(3 downto 0) <= vdata1(11 downto 8);
          Green(3 downto 0) <= vdata1(7 downto 4);
          Blue(3 downto 0) <= vdata1(3 downto 0);
        elsif hcounter >= hpos2 and hcounter < 64 + hpos2 and vcounter >= vpos2 and vcounter < 64 + vpos2 then
          Red(3 downto 0) <= vdata2(11 downto 8);
          Green(3 downto 0) <= vdata2(7 downto 4);
          Blue(3 downto 0) <= vdata2(3 downto 0);
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

  do_movement: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if (vcounter = vt_vis and hcounter = 0) then
        if hdir1 = '1' then
          hpos1 <= hpos1 + 1;
        else
          hpos1 <= hpos1 - 1;
        end if;

        if vdir1 = '1' then
          vpos1 <= vpos1 + 1;
        else
          vpos1 <= vpos1 - 1;
        end if;

        if hdir2 = '1' then
          hpos2 <= hpos2 + 1;
        else
          hpos2 <= hpos2 - 1;
        end if;

        if vdir2 = '1' then
          vpos2 <= vpos2 + 1;
        else
          vpos2 <= vpos2 - 1;
        end if;
      end if;
    end if;
  end process;

  do_bounds_check: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if hpos1 = ht_vis - 64 then
        hdir1 <= '0';
      elsif hpos1 = 0 then
        hdir1 <= '1';
      end if;

      if vpos1 = vt_vis - 64 then
        vdir1 <= '0';
      elsif vpos1 = 0 then
        vdir1 <= '1';
      end if;

      if hpos2 = ht_vis - 64 then
        hdir2 <= '0';
      elsif hpos2 = 0 then
        hdir2 <= '1';
      end if;

      if vpos2 = vt_vis - 64 then
        vdir2 <= '0';
      elsif vpos2 = 0 then
        vdir2 <= '1';
      end if;
    end if;
  end process;

end Behavioral;
