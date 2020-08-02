library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity audio_wave is
  port (
    AUDIO : out STD_LOGIC;
    clk   : in  STD_LOGIC
  );
end audio_wave;

architecture Behavioral of audio_wave is
  component dac8
    port (
      clk   : in  STD_LOGIC;
      data  : in  STD_LOGIC_VECTOR(7 downto 0);
      pulse : out STD_LOGIC
    );
  end component;

  component memory
    port (
      clka  : IN STD_LOGIC;
      addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  end component;

  -- used to choose which value from memory to send to the DAC
  signal addr    : STD_LOGIC_VECTOR(9 downto 0);
  signal counter : STD_LOGIC_VECTOR(29 downto 0);

  -- the current value retrieved from memory
  signal data    : STD_LOGIC_VECTOR(7 downto 0);

begin

  dac: dac8
    port map (
      clk => counter(15),
      data => data,
      pulse => AUDIO
    );

  sine: memory
    port map (
      clka => clk,
      addra => addr,
      douta => data
    );

  -- use highest 10 bits of counter to choose memory address
  addr <= counter(15 downto 6);

  process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
    end if;
  end process;

end Behavioral;
