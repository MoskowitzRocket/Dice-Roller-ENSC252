LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

Entity NumSides is
PORT(
	side_select : in std_logic_vector(9 DOWNTO 4);
	sides : out integer
);
END NumSides;

ARCHITECTURE behaviour of NumSides is

BEGIN

	process(side_select)
	BEGIN
		case side_select is
			when "100000" => sides <= 20;
			when "010000" => sides <= 12;
			when "001000" => sides <= 10;
			when "000100" => sides <= 8;
			when "000010" => sides <= 6;
			when "000001" => sides <= 4;
			when OTHERS => sides <= 1;
		end case;
	end process;


END behaviour;