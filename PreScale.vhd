--Kale Moskowitz - 301588993; Veronica Young 301596679; Edward Cao 301594924

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PreScale is
GENERIC(
	DATA_WIDTH : INTEGER := 20 --Defaults to 20 bit
);
PORT(InClock : in std_logic;
	 OutClock : out std_logic);
END PreScale;

Architecture upcount of PreScale is

	SIGNAL accumulator : UNSIGNED(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

begin
	
	PROCESS(InClock)
	BEGIN
		IF rising_edge(InClock) THEN
			accumulator <= accumulator + 1;
		END IF;
	END PROCESS;
	
	OutClock <= accumulator(DATA_WIDTH - 1);
	
END upcount;

