library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rs232_echo is
  port (
    CLK : in  STD_LOGIC;
    RX  : in  STD_LOGIC;
    TX  : out STD_LOGIC
  );
end rs232_echo;

architecture Behavioral of rs232_echo is
  component rs232_rx
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
  end component;

  component rs232_tx
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
  end component;

  signal echo : STD_LOGIC_VECTOR(7 downto 0);
  signal set  : STD_LOGIC;

begin

  inst_rs232_rx: rs232_rx
    generic map (
      frequency => 32000000,
      baud => 9600
    )
    port map (
      clk => CLK,
      rx => RX,
      data => echo,
      data_strobe => set
    );

  inst_rs232_tx: rs232_tx
    generic map (
      frequency => 32000000,
      baud => 9600
    )
    port map (
      clk => CLK,
      data => echo,
      set => set,
      tx => TX
    );

end Behavioral;
