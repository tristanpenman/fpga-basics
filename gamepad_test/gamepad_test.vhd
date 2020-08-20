library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gamepad_test is
  Port (
    clk   : in    STD_LOGIC;
    HSYNC : out   STD_LOGIC;
    VSYNC : inout STD_LOGIC;
    Red   : out   STD_LOGIC_VECTOR (3 downto 0);
    Green : out   STD_LOGIC_VECTOR (3 downto 0);
    Blue  : out   STD_LOGIC_VECTOR (3 downto 0);
    JOY_G : out   STD_LOGIC;
    JOY_D : in    STD_LOGIC;
    JOY_L : in    STD_LOGIC;
    JOY_R : in    STD_LOGIC;
    JOY_U : in    STD_LOGIC
  );
end gamepad_test;

architecture Behavioral of gamepad_test is
  signal hcounter : STD_LOGIC_VECTOR (9 downto 0);
  signal hpos     : STD_LOGIC_VECTOR (9 downto 0);
  signal vcounter : STD_LOGIC_VECTOR (9 downto 0);
  signal vpos     : STD_LOGIC_VECTOR (9 downto 0);

  signal clk_out1 : STD_LOGIC;

  constant ht_vis  : integer := 640;
  constant ht_fp   : integer := 16;
  constant ht_sync : integer := 96;
  constant ht_bp   : integer := 48;

  constant vt_vis  : integer := 480;
  constant vt_fp   : integer := 10;
  constant vt_sync : integer := 2;
  constant vt_bp   : integer := 33;

  component clock_divider
  port(
    -- Clock in ports
    CLK_IN1           : in     std_logic;
    -- Clock out ports
    CLK_OUT1          : out    std_logic
  );
  end component;

begin

  -- ground
  JOY_G <= '0';

  clock : clock_divider
  port map(
    -- Clock in ports
    CLK_IN1 => clk,
    -- Clock out ports
    CLK_OUT1 => clk_out1
  );

  do_input: process(VSYNC)
  begin
    if rising_edge(VSYNC) then
      if not(JOY_R = '1') then
        if hpos < ht_vis - 1 then
          hpos <= hpos + 1;
        end if;
      elsif not(JOY_L = '1') then
        if hpos > 0 then
          hpos <= hpos - 1;
        end if;
      end if;
      if not(JOY_D = '1') then
        if vpos < vt_vis - 1 then
          vpos <= vpos + 1;
        end if;
      elsif not(JOY_U = '1') then
        if vpos > 0 then
          vpos <= vpos - 1;
        end if;
      end if;
    end if;
  end process;

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

  do_rgb: process(clk_out1)
  begin
    if rising_edge(clk_out1) then
      if hcounter < ht_vis and vcounter < vt_vis then
        if hcounter = hpos or vcounter = vpos then
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
