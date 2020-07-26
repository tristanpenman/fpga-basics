library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity simple_vga is
    Port ( clk    : in   STD_LOGIC;
           HSYNC  : out  STD_LOGIC;
           VSYNC  : out  STD_LOGIC;
           Red    : out  STD_LOGIC_VECTOR (2 downto 0);
           Green  : out  STD_LOGIC_VECTOR (2 downto 0);
           Blue   : out  STD_LOGIC_VECTOR (2 downto 1));
end simple_vga;

architecture Behavioral of simple_vga is

component clock_divider
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic
 );
end component;

signal hcounter : STD_LOGIC_VECTOR (9 downto 0);
signal vcounter : STD_LOGIC_VECTOR (9 downto 0);

signal clk_out1 : STD_LOGIC;

constant ht_vis  : integer := 640;
constant ht_fp   : integer := 16;
constant ht_sync : integer := 96;
constant ht_bp   : integer := 48;

constant vt_vis  : integer := 480;
constant vt_fp   : integer := 10;
constant vt_sync : integer := 2;
constant vt_bp   : integer := 33;

begin

clock : clock_divider
  port map
   (-- Clock in ports
    CLK_IN1 => clk,
    -- Clock out ports
    CLK_OUT1 => clk_out1);

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
        if hcounter(3) = '1' then
          Red(2 downto 0) <= "111";
        else
          Red(2 downto 0) <= "100";
        end if;
        if vcounter(3) = '1' then
          Green(2 downto 0) <= "111";
        else
          Green(2 downto 0) <= "100";
        end if;
        Blue(2 downto 1) <= "11";
      else
        Red(2 downto 0) <= "000";
        Green(2 downto 0) <= "000";
        Blue(2 downto 1) <= "00";
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

