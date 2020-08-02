library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dac8 is
  port (
    clk   : in  STD_LOGIC;
    data  : in  STD_LOGIC_VECTOR(7 downto 0);
    pulse : out STD_LOGIC
  );
end dac8;

architecture Behavioral of dac8 is
  signal sum : STD_LOGIC_VECTOR(8 downto 0);
begin
  pulse <= sum(8);

  process (clk, sum)
  begin
    if rising_edge(clk) then
      sum <= ("0" & sum(7 downto 0)) + ("0" & data);
    end if;
  end process;

end Behavioral;
