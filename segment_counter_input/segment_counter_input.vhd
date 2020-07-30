library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity segment_counter_input is
  Port (
    anodes     : out STD_LOGIC_VECTOR (3 downto 0);
    segs       : out STD_LOGIC_VECTOR (6 downto 0);
    LED        : out STD_LOGIC_VECTOR (7 downto 0);
    dp         : out STD_LOGIC;
    clk        : in  STD_LOGIC;
    JOY_L      : in  STD_LOGIC;
    JOY_R      : in  STD_LOGIC;
    JOY_SELECT : in  STD_LOGIC
  );
end segment_counter_input;

architecture Behavioral of segment_counter_input is
  signal counter_a : STD_LOGIC_VECTOR (35 downto 0);
  signal counter_b : STD_LOGIC_VECTOR (15 downto 0);
  signal counter_c : STD_LOGIC_VECTOR (25 downto 0);
  signal digit     : STD_LOGIC_VECTOR (3 downto 0);
  signal direction : STD_LOGIC_VECTOR (1 downto 0);
begin
  dp <= '1';

  LED(7) <= NOT(JOY_R);
  LED(6) <= NOT(JOY_R);
  LED(5) <= NOT(JOY_R);
  LED(4) <= NOT(JOY_R);

  LED(3) <= NOT(JOY_L);
  LED(2) <= NOT(JOY_L);
  LED(1) <= NOT(JOY_L);
  LED(0) <= NOT(JOY_L);

  set_direction: process(clk)
  begin
    if rising_edge(clk) then
      if NOT(JOY_R = '1') AND JOY_L = '1' then
        direction <= "10";
      elsif NOT(JOY_L = '1') AND JOY_R = '1' then
        direction <= "01";
      else
        direction <= "00";
      end if;

      if JOY_SELECT = '0' then
        counter_c <= counter_c + 1;
      else
        counter_c <= (others => '0');
      end if;
    end if;
  end process;

  increment_counters: process(clk)
  begin
    if rising_edge(clk) then
      if counter_c(25) = '1' then
        counter_a <= (others => '0');
      else
        -- Change counter depending on direction
        case direction(1 downto 0) is
        when "10" =>
          counter_a <= counter_a + 1;
        when "01" =>
          counter_a <= counter_a - 1;
        when others =>
          counter_a <= counter_a;
        end case;
      end if;

      counter_b <= counter_b + 1;
    end if;
  end process;

  update_digits: process(counter_a, counter_b)
  begin
    case counter_b(15 downto 14) is
      -- First two cases cover the low order byte
      when "00" =>
        anodes <= "1110";
        digit <= counter_a(23 downto 20);
      when "01" =>
        anodes <= "1101";
        digit <= counter_a(27 downto 24);
      -- Next two cases cover the high order byte
      when "10" =>
        anodes <= "1011";
        digit <= counter_a(31 downto 28);
      when others =>
        anodes <= "0111";
        digit <= counter_a(35 downto 32);
    end case;
  end process;

  update_segments: process(digit)
  begin
    -- Map the current digit to the seven segment display
    case digit is
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
