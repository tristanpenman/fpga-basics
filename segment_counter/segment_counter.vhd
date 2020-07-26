library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity segment_counter is
    Port ( anodes : out STD_LOGIC_VECTOR (3 downto 0);
           segs   : out STD_LOGIC_VECTOR (6 downto 0);
			  LED    : out STD_LOGIC_VECTOR (7 downto 0);
           dp     : out STD_LOGIC;
           clk    : in  STD_LOGIC
         );
end segment_counter;

architecture Behavioral of segment_counter is
  signal counter : STD_LOGIC_VECTOR (35 downto 0);
  signal digit   : STD_LOGIC_VECTOR (3 downto 0);
begin
  dp <= '1';

  handle_clk: process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;

		-- Show the high order byte on the LEDs
		LED <= counter(35 downto 28);

      case counter(15 downto 14) is
		  -- First two cases cover the low order byte
        when "00" =>
          anodes <= "1110";
          digit <= counter(23 downto 20);
        when "01" => 
          anodes <= "1101";
          digit <= counter(27 downto 24);
		  -- Next two cases cover the high order byte
        when "10" => 
          anodes <= "1011";
          digit <= counter(31 downto 28);
        when "11" =>
          anodes <= "0111";
          digit <= counter(35 downto 32);
		  -- This should never happen
        when others =>
          anodes <= "1111";
          digit <= "ZZZZ";
      end case;
		
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
        when "1111" => segs <= "0001110";
        when others => segs <= "1111111";
      end case;
    end if;
  end process;

end Behavioral;
