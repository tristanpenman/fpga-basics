library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity volume_control is
  port (
    AUDIO  : out STD_LOGIC;
    anodes : out STD_LOGIC_VECTOR (3 downto 0);
    clk    : in  STD_LOGIC;
    JOY_L  : in  STD_LOGIC;
    JOY_R  : in  STD_LOGIC;
    segs   : out STD_LOGIC_VECTOR (6 downto 0)
  );
end volume_control;

architecture Behavioral of volume_control is
  component dac8
    port (
      clk   : in  STD_LOGIC;
      data  : in  STD_LOGIC_VECTOR(7 downto 0);
      pulse : out STD_LOGIC
    );
  end component;

  component memory
    port (
      clka  : in  STD_LOGIC;
      addra : in  STD_LOGIC_VECTOR(9 downto 0);
      douta : out STD_LOGIC_VECTOR(7 downto 0)
    );
  end component;

  component multiplier
    port (
      clk : in  STD_LOGIC;
      a   : in  STD_LOGIC_VECTOR(7 downto 0);
      b   : in  STD_LOGIC_VECTOR(3 downto 0);
      p   : out STD_LOGIC_VECTOR(11 downto 0)
    );
  end component;

  signal addr    : STD_LOGIC_VECTOR(9 downto 0);
  signal counter : STD_LOGIC_VECTOR(26 downto 0);
  signal data1   : STD_LOGIC_VECTOR(7 downto 0);
  signal data2   : STD_LOGIC_VECTOR(11 downto 0);
  signal volume  : STD_LOGIC_VECTOR(3 downto 0) := "1111";

begin

  -- avoid burning out the leds
  set_anodes: process(clk, counter)
  begin
    if rising_edge(clk) then
      if counter(18 downto 14) = "11111" then
        anodes <= "1110";
      else
        anodes <= "1111";
      end if;
    end if;
  end process;

  set_volume: process(counter(21))
  begin
    if rising_edge(counter(21)) then
      if NOT(JOY_R = '1') AND JOY_L = '1' AND NOT(volume = "1111") then
        volume <= volume + 1;
      elsif NOT(JOY_L = '1') AND JOY_R = '1' AND NOT(volume = "0000") then
        volume <= volume - 1;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
    end if;
  end process;

  -- use highest 10 bits of counter to choose memory address
  addr <= counter(15 downto 6);

  mem: memory
    port map (
      clka => counter(6),
      addra => addr,
      douta => data1
    );
    
  -- multiply data by b
  mul: multiplier
    port map (
      clk => counter(6),
      a => data1,
      b => volume,
      p => data2
    );
    
  -- feed result to the dac
  dac: dac8
    port map (
      clk => clk,
      data => data2(11 downto 4),
      pulse => AUDIO
    );

  update_segments: process(volume)
  begin
    -- Map the current digit to the seven segment display
    case volume is
      when "0000" => segs <= "1000000";
      when "0001" => segs <= "1111001";
      when "0010" => segs <= "0100100";
      when "0011" => segs <= "0110000";
      when "0100" => segs <= "0011001";
      when "0101" => segs <= "0010010";
      when "0110" => segs <= "0000010";
      when "0111" => segs <= "1111000";
      when "1000" => segs <= "0000000";
      when "1001" => segs <= "0011000";
      when "1010" => segs <= "0001000";
      when "1011" => segs <= "0000011";
      when "1100" => segs <= "1000110";
      when "1101" => segs <= "0100001";
      when "1110" => segs <= "0000110";
      when others => segs <= "0001110";
    end case;
  end process;
 
end Behavioral;

