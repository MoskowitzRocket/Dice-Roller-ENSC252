--Kale Moskowitz - 301588993; Veronica Young 301596679; Edward Cao 301594924

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


ENTITY TestDice is
PORT(
	SW: in std_logic_vector(9 DOWNTO 0);
	KEY : in std_logic_vector(3 DOWNTO 0);
	CLOCK_50 : in std_logic;
	
	HEX0 : out std_logic_vector(6 DOWNTO 0);
	HEX1 : out std_logic_vector(6 DOWNTO 0);
	HEX2 : out std_logic_vector(6 DOWNTO 0);
	HEX3 : out std_logic_vector(6 DOWNTO 0);
	HEX4 : out std_logic_vector(6 DOWNTO 0);
	HEX5 : out std_logic_vector(6 DOWNTO 0);
	LEDR : out std_logic_vector(9 DOWnTO 0)

);
END ENTITY;

Architecture test of TestDice is
	COMPONENT PreScale is
	GENERIC(
		DATA_WIDTH : INTEGER := 20 --Defaults to 20 bit
		);
	PORT(InClock : in std_logic;
		OutClock : out std_logic);
	END COMPONENT;
	
	COMPONENT DiceRoller is
	GENERIC (
			SEED : UNSIGNED(15 DOWNTO 0) := x"1f35"
	 );
    PORT (
        CLK         : IN  STD_LOGIC; -- Clock signal
        Button         : IN  STD_LOGIC; -- Key press input
		  MAX_SIDES : IN INTEGER;
		  STOP_ROLL        : IN STD_LOGIC;
		  RESET_ROLL 		: IN STD_LOGIC;
        SEG_0         : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display
		  SEG_1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display
		  Configurable : OUT STD_LOGIC
    );
	END COMPONENT;
	
		
	COMPONENT NumDice is
	PORT(
		number_select : in std_logic_vector(3 DOWNTO 1);
		number : out integer range 1 to 3 := 1
	);
	END COMPONENT;
	
	COMPONENT Debouncer is
	PORT(
		side_Sw : in std_logic_vector(9 DOWNTO 4);
		num_Sw  : in std_logic_vector(3 DOWNTO 1);
		enable_Sw : in std_logic_vector(0 DOWNTO 0);
		key_in : in std_logic_vector(3 DOWNTO 0);

		clk : in std_logic;
		SW_debounced : out std_logic_vector(9 DOWNTO 0);
		key_debounced : out std_logic_vector(3 DOWNTO 0)

	);
	END Component;
	
	SIGNAL clk_scaled1 : std_logic;
	SIGNAL clk_scaled2 : std_logic;
	SIGNAL clk_scaled3 : std_logic;

	signal max_sides : integer;
	signal max_dice : integer;
	
   SIGNAL stop_dice : std_logic;
	SIGNAL reset_dice : std_logic;
	 
	signal hex0_out : std_logic_vector(6 DOWNTO 0);
	signal hex1_out : std_logic_vector(6 DOWNTO 0);
	signal hex2_out : std_logic_vector(6 DOWNTO 0);
	signal hex3_out : std_logic_vector(6 DOWNTO 0);
	signal hex4_out : std_logic_vector(6 DOWNTO 0);
	signal hex5_out : std_logic_vector(6 DOWNTO 0);
	
	signal debounced_switches : std_logic_vector(9 DOWNTO 0);
	signal debounced_keys : std_logic_vector(3 DOWNTO 0);
	
	signal configurable : std_logic;
	signal last_max_sides : integer;
	
BEGIN

	d1 : Debouncer
	PORT MAP(
		side_Sw => SW(9 DOWNTO 4),
		num_Sw => SW(3 DOWNTO 1),
		enable_Sw => Sw(0 DOWNTO 0),
		key_in => KEY(3 DOWNTO 0),
		clk => CLOCK_50,
		SW_debounced => debounced_switches,
		key_debounced => debounced_keys
	);

	
	p1 : PreScale
	GENERIC MAP( DATA_WIDTH => 20)
	PORT MAP( InClock => CLOCK_50, OutClock => clk_scaled1);
	
	
	process(debounced_switches)
	begin
		case debounced_switches(9 DOWNTO 4) is
				when "100000" => LEDR(9 DOWNTO 4) <= "100000";
				when "010000" => LEDR(9 DOWNTO 4) <= "010000";
				when "001000" => LEDR(9 DOWNTO 4) <= "001000";
				when "000100" => LEDR(9 DOWNTO 4) <= "000100";
				when "000010" => LEDR(9 DOWNTO 4) <= "000010";
				when "000001" => LEDR(9 DOWNTO 4) <= "000001";
				when others   => LEDR(9 DOWNTO 4) <= "101010"; -- Default to 1 side
		  end case;
	end process;
	
	process(debounced_switches, configurable)
	begin
		 if configurable = '1' then
			  -- Allow changing max_sides only when configurable is '1'
			  case debounced_switches(9 DOWNTO 4) is
					when "100000" => max_sides <= 20;
					when "010000" => max_sides <= 12;
					when "001000" => max_sides <= 10;
					when "000100" => max_sides <= 8;
					when "000010" => max_sides <= 6;
					when "000001" => max_sides <= 4;
					when others    => max_sides <= 1; -- Default to 1 side
			  end case;
			  -- Update last_max_sides with the new value
			  last_max_sides <= max_sides;
		 else
			  -- Retain the previous value when configurable is '0'
			  max_sides <= last_max_sides;
		 end if;
	end process;
		
			
	
	n2 : NumDice
	PORT MAP(number_select => debounced_switches(3 DOWNTO 1), number => max_dice);
	
	process(debounced_keys)
    BEGIN -- Stop logic controlled by KEY(1)
        IF debounced_keys(1) = '0' THEN
            stop_dice <= '1'; -- Stops the dice if KEY(1) is pressed
        ELSE
            stop_dice <= '0'; -- Allows the program to continue running
        END IF;
		  IF debounced_keys(2) = '0' THEN
				reset_dice <= '1';
		  ELSE
				reset_dice <= '0';
		  END IF;
    END PROCESS;
		
	dr1 : DiceRoller
	GENERIC MAP(SEED => x"1234")
	PORT MAP(CLK => clk_scaled1, 
				BUTTON => debounced_keys(0), 
				STOP_ROLL => stop_dice, 
				RESET_ROLL => reset_dice, 
				MAX_SIDES => max_sides, 
				SEG_0 => hex0_out, 
				SEG_1 => hex1_out, 
				Configurable => configurable);
 
	dr2 : DiceRoller
	GENERIC MAP(SEED => x"54CE")
	PORT MAP(CLK => clk_scaled1, 
				BUTTON => debounced_keys(0), 
				STOP_ROLL => stop_dice, 
				RESET_ROLL => reset_dice,
				MAX_SIDES => max_sides, 
				SEG_0 => hex2_out, 
				SEG_1 => hex3_out, 
				Configurable => open);
	
	dr3 : DiceRoller
	GENERIC MAP(SEED => x"ABF2")
	PORT MAP(CLK => clk_scaled1, 
				BUTTON => debounced_keys(0), 
				STOP_ROLL => stop_dice, 
				RESET_ROLL => reset_dice, 
				MAX_SIDES => max_sides, 
				SEG_0 => hex4_out, 
				SEG_1 => hex5_out, 
				Configurable => open);
	
	
	PROCESS(max_dice)
	BEGIN
		 -- Turn off unused HEX displays
		 CASE max_dice IS
			  WHEN 0 =>
					HEX0 <= (OTHERS => '1');
					HEX1 <= (OTHERS => '1');
					HEX2 <= (OTHERS => '1'); -- Turn off
					HEX3 <= (OTHERS => '1'); -- Turn off
					HEX4 <= (OTHERS => '1'); -- Turn off
					HEX5 <= (OTHERS => '1'); -- Turn off
					LEDR(3 DOWNTO 1) <= "000";

			  WHEN 1 =>
					HEX0 <= hex0_out;
					HEX1 <= hex1_out;
					HEX2 <= (OTHERS => '1'); -- Turn off
					HEX3 <= (OTHERS => '1'); -- Turn off
					HEX4 <= (OTHERS => '1'); -- Turn off
					HEX5 <= (OTHERS => '1'); -- Turn off
					LEDR(3 DOWNTO 1) <= "001";
			  WHEN 2 =>
					HEX0 <= hex0_out;
					HEX1 <= hex1_out;
					HEX2 <= hex2_out;
					HEX3 <= hex3_out;
					HEX4 <= (OTHERS => '1'); -- Turn off
					HEX5 <= (OTHERS => '1'); -- Turn off
					LEDR(3 DOWNTO 1) <= "010";
			  WHEN 3 =>
					HEX0 <= hex0_out;
					HEX1 <= hex1_out;
					HEX2 <= hex2_out;
					HEX3 <= hex3_out;
					HEX4 <= hex4_out;
					HEX5 <= hex5_out;
					LEDR(3 DOWNTO 1) <= "100";
			  WHEN OTHERS =>
					HEX0 <= (OTHERS => '1'); -- Default off
					HEX1 <= (OTHERS => '1');
					HEX2 <= (OTHERS => '1');
					HEX3 <= (OTHERS => '1');
					HEX4 <= (OTHERS => '1');
					HEX5 <= (OTHERS => '1');
					LEDR(3 DOWNTO 1) <= "000";
		 END CASE;
	END PROCESS;
		
END test;