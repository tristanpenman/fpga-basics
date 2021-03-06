library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rs232_rx is
  generic (
    frequency   : natural;
    baud        : natural
  );
  port (
    clk         : in  STD_LOGIC;
    rx          : in  STD_LOGIC;
    data        : out STD_LOGIC_VECTOR(7 downto 0);
    data_strobe : out STD_LOGIC
  );
end rs232_rx;

architecture Behavioral of rs232_rx is
  signal oversampled_bits : STD_LOGIC_VECTOR(39 downto 0);
  signal baud_x4          : unsigned(11 downto 0) := (others => '0');
begin

  process(clk)
  begin
    if rising_edge(clk) then
      data_strobe <= '0';

      if baud_x4 = 0 then
        if oversampled_bits(39 downto 37) = "000" then
          data_strobe <= '1';
          data <= oversampled_bits(6)  & oversampled_bits(10)
                & oversampled_bits(14) & oversampled_bits(18)
                & oversampled_bits(22) & oversampled_bits(26)
                & oversampled_bits(30) & oversampled_bits(34);
          oversampled_bits(39 downto 1) <= (others => '1');
          oversampled_bits(0) <= rx;
        else
          oversampled_bits <= oversampled_bits(38 downto 0) & rx;
        end if;
      end if;

      if baud_x4 = frequency / (baud * 4) - 1 then
        baud_x4 <= (others => '0');
      else
        baud_x4 <= baud_x4 + 1;
      end if;
    end if;
  end process;

end Behavioral;
