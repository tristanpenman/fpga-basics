library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rs232_tx is
  generic (
    frequency   : natural;
    baud        : natural
  );
  port (
    clk         : in  STD_LOGIC;
    tx          : out STD_LOGIC;
    set         : in  STD_LOGIC;
    data        : in  STD_LOGIC_VECTOR(7 downto 0)
  );
end rs232_tx;

architecture Behavioral of rs232_tx is
  signal available : STD_LOGIC := '0';
  signal buff      : STD_LOGIC_VECTOR(7 downto 0)  := (others => '1');
  signal counter   : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
  signal sent      : STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
  signal shiftreg  : STD_LOGIC_VECTOR(8 downto 0)  := (others => '1');
begin

  tx <= shiftreg(0);

  process(clk)
  begin
    if rising_edge(clk) then
      if set = '1' then
        available <= '1';
        buff <= data;
      end if;

      if counter = 3332 then
        counter <= (others => '0');
        if sent = 15 then
          if available = '0' then
            -- keep sending ones to indicate that no input is available
            shiftreg <= (others => '1');
          else
            -- echo the byte back
            shiftreg <= buff & "0";
          end if;
          available <= '0';
          sent <= (others => '0');
        else
          shiftreg <= '1' & shiftreg(8 downto 1);
          sent <= sent + 1;
        end if;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

end Behavioral;
