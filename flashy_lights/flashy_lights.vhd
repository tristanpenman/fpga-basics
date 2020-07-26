library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity flashy_lights is
  port ( clk  : in   STD_LOGIC;
         LEDs : out  STD_LOGIC_VECTOR (7 downto 0));
end flashy_lights;

architecture Behavioral of flashy_lights is
  component memory
    port (
      clka : IN STD_LOGIC;
      addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  end component;
  
  signal count : STD_LOGIC_VECTOR(22 DOWNTO 0);
  signal addr  : STD_LOGIC_VECTOR(9 DOWNTO 0);
begin

update_count: process(clk)
  begin
    if rising_edge(clk) then  
      count <= count + 1;
    end if;
  end process;

update_addr: process(count)
  begin
    if rising_edge(count(22)) then
      if addr >= 17 then  -- 17 binary
        addr <= (others => '0');
      else
        addr <= addr + 1;
      end if;
    end if;
  end process;

rom_memory : memory
  port map (
    clka => clk,
    addra => addr,
    douta => LEDs
  );

end Behavioral;
