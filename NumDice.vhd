LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY NumDice is
PORT(
	number_select : in std_logic_vector(3 DOWNTO 1);
	number : out integer range 0 to 3 := 1
);
END NumDice;

Architecture choose of NumDice is

BEGIN
	process(number_select)
	BEGIN
	case number_select is
		when "100" => number <= 3;
		when "010" => number <= 2;
		when "001" => number <= 1;
		when others => number <= 0;
	end case;
	end process;

END choose;