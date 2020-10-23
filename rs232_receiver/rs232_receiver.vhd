library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rs232_receiver is
  port (
    CLK : in  STD_LOGIC;
    RX  : in  STD_LOGIC;
    LED : out STD_LOGIC_VECTOR(7 downto 0)
  );
end rs232_receiver;

architecture Behavioral of rs232_receiver is
  component rs232_rx
    generic (
      frequency   : natural;
      baud        : natural
    );
    port (
      clk         : in  STD_LOGIC;
      rx          : in  STD_LOGIC;
      data        : out STD_LOGIC_VECTOR(7 downto 0)
    );
  end component;

begin

  inst_rs232_rx: rs232_rx
    generic map (
      frequency => 32000000,
      baud => 9600
    )
    port map (
      clk => CLK,
      rx => RX,
      data => LED
    );

end Behavioral;
