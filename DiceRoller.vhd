LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

ENTITY DiceRoller IS
	 GENERIC (
			SEED : UNSIGNED(15 DOWNTO 0) := x"1f35"
	 );
    PORT (
        CLK         : IN  STD_LOGIC; -- Clock signal
        Button         : IN  STD_LOGIC; -- Key press input
		  MAX_SIDES : IN INTEGER := 6;
		  STOP_ROLL : IN std_logic;
		  RESET_ROLL : IN STD_LOGIC;
        SEG_0         : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display
		  SEG_1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display
		  Configurable : OUT STD_LOGIC
		  
    );
END DiceRoller;


ARCHITECTURE Behavioral OF DiceRoller IS
    -- FSM State Definitions
    TYPE State_Type IS (IDLE, ROLLING, ROLLED);
    SIGNAL FSM_State : State_Type := IDLE;

    SIGNAL random_num : INTEGER RANGE 1 TO 20;
    SIGNAL hex_out_ones : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL hex_out_tens : STD_LOGIC_VECTOR(6 DOWNTO 0);

    SIGNAL lfsr : UNSIGNED(15 DOWNTO 0) := SEED;
    SIGNAL feedback : STD_LOGIC;

	 
	 SIGNAL rolling_counter : INTEGER := 0; -- Counter for animation duration
    SIGNAL rolling_limit : INTEGER := 100; -- Randomized limit for rolling
	 
BEGIN
    PROCESS(CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            CASE FSM_State IS
                WHEN IDLE =>
						  Configurable <= '1';
                    rolling_counter <= 0; -- Reset counter
                    IF Button = '1' THEN
                        -- Randomize rolling limit using LFSR
                        feedback <= lfsr(15) XOR lfsr(13) XOR lfsr(12) XOR lfsr(10);
                        lfsr <= feedback & lfsr(15 DOWNTO 1);
                        rolling_limit <= TO_INTEGER(lfsr MOD 100) + 50; -- Limit between 50 and 150
                        FSM_State <= ROLLING;
                    END IF;

                WHEN ROLLING =>
							Configurable <= '0';
							if STOP_ROLL = '1' then
								FSM_State <= ROLLED;
							END IF;
							
							if RESET_ROLL = '1' then
								random_num <= 1;
								FSM_State <= ROLLED;
							END IF;
							
                    -- Update LFSR for animation effect
                    feedback <= lfsr(15) XOR lfsr(13) XOR lfsr(12) XOR lfsr(10);
                    lfsr <= feedback & lfsr(15 DOWNTO 1);
                    random_num <= TO_INTEGER(lfsr MOD MAX_SIDES) + 1;

                    -- Increment rolling counter
                    rolling_counter <= rolling_counter + 1;
                    
                    -- Transition to ROLLED state after reaching the random limit
                    IF rolling_counter >= rolling_limit THEN
                        FSM_State <= ROLLED;
                    END IF;

                WHEN ROLLED =>
                    -- Wait for button release to reset
                    IF Button = '0' THEN
                        FSM_State <= IDLE;
                    END IF;
						  
						  if RESET_ROLL = '1' then
								random_num <= 1;
						  END IF;
						  
            END CASE;
        END IF;
    END PROCESS;
    -- Assign random number and decode to 7-segment displays
    PROCESS(random_num)
    BEGIN
        CASE random_num MOD 10 IS
            WHEN 1 => hex_out_ones <= "1111001"; -- Display "1"
            WHEN 2 => hex_out_ones <= "0100100"; -- Display "2"
            WHEN 3 => hex_out_ones <= "0110000"; -- Display "3"
            WHEN 4 => hex_out_ones <= "0011001"; -- Display "4"
            WHEN 5 => hex_out_ones <= "0010010"; -- Display "5"
            WHEN 6 => hex_out_ones <= "0000010"; -- Display "6"
            WHEN 7 => hex_out_ones <= "1111000"; -- Display "7"
            WHEN 8 => hex_out_ones <= "0000000"; -- Display "8"
            WHEN 9 => hex_out_ones <= "0010000"; -- Display "9"
            WHEN 0 => hex_out_ones <= "1000000"; -- Display "0"
            WHEN OTHERS => hex_out_ones <= "1111111"; -- Default
        END CASE;
    END PROCESS;

    PROCESS(random_num)
    BEGIN
        CASE random_num / 10 IS
            WHEN 1 => hex_out_tens <= "1111001"; -- Display "1"
            WHEN 2 => hex_out_tens <= "0100100"; -- Display "2"
            WHEN OTHERS => hex_out_tens <= "1111111"; -- Blank display
        END CASE;
    END PROCESS;

    -- Drive HEX0 with ones digit and HEX1 with tens digit
    SEG_0 <= hex_out_ones;
    SEG_1 <= hex_out_tens;
END Behavioral;
