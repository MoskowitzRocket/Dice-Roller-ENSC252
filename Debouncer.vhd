LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Debouncer is
PORT(
side_Sw : in std_logic_vector(9 DOWNTO 4);
num_Sw  : in std_logic_vector(3 DOWNTO 1);
enable_Sw : in std_logic_vector(0 DOWNTO 0);
key_in : in std_logic_vector(3 DOWNTO 0);
clk : in std_logic;
SW_debounced : out std_logic_vector(9 DOWNTO 0);
key_debounced : out std_logic_vector(3 DOWNTO 0)
);
END Debouncer;

Architecture debounce of Debouncer is
	 CONSTANT DEBOUNCE_LIMIT : INTEGER := 500000; -- 10 ms debounce time for 50 MHz clock
    CONSTANT COUNTER_WIDTH  : INTEGER := 19; -- Width of counter: ceil(log2(DEBOUNCE_LIMIT))

    -- Separate counters for each key
    SIGNAL counter0 : STD_LOGIC_VECTOR(COUNTER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter1 : STD_LOGIC_VECTOR(COUNTER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter2 : STD_LOGIC_VECTOR(COUNTER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter3 : STD_LOGIC_VECTOR(COUNTER_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

    -- Stable states for each key
    SIGNAL stable0 : STD_LOGIC := '0';
    SIGNAL stable1 : STD_LOGIC := '0';
    SIGNAL stable2 : STD_LOGIC := '0';
    SIGNAL stable3 : STD_LOGIC := '0';


	SIGNAL state_A : STD_LOGIC_VECTOR(9 DOWNTO 4) := (OTHERS => '0'); -- Internal state for group A
    SIGNAL state_B : STD_LOGIC_VECTOR(3 DOWNTO 1) := (OTHERS => '0'); -- Internal state for group B
    SIGNAL state_C : STD_LOGIC := '0';                                -- Internal state for group C
BEGIN
    PROCESS (clk)
    BEGIN
			IF RISING_EDGE(clk) THEN
            -- Group A: SW[9..4]
				 CASE side_Sw(9 DOWNTO 4) IS
					  WHEN "100000" => 
							state_A <= "100000"; -- side_Sw[9] activated
					  WHEN "010000" => 
							state_A <= "010000"; -- side_Sw[8] activated
					  WHEN "001000" => 
							state_A <= "001000"; -- side_Sw[7] activated
					  WHEN "000100" => 
							state_A <= "000100"; -- side_Sw[6] activated
					  WHEN "000010" => 
							state_A <= "000010"; -- side_Sw[5] activated
					  WHEN "000001" => 
							state_A <= "000001"; -- side_Sw[4] activated
					  WHEN OTHERS => 
							state_A <= "000000"; -- No valid switch activated
				 END CASE;
            
				-- Group B: SW[3..1]
				IF num_Sw(3 DOWNTO 1) = "100" THEN
					 state_B <= "100"; -- num_Sw[3] activated
				ELSIF num_Sw(3 DOWNTO 1) = "010" THEN
					 state_B <= "010"; -- num_Sw[2] activated
				ELSIF num_Sw(3 DOWNTO 1) = "001" THEN
					 state_B <= "001"; -- num_Sw[1] activated
				ELSE
					 state_B <= "000"; -- Invalid or no switches active
				END IF;
            
            -- Group C: SW[0]
            IF enable_Sw(0) = '1' THEN
                state_C <= '1'; -- enable_Sw[0] activated
				ELSIF enable_Sw(0) = '0' THEN
					state_c <= '0';
            END IF;
				
				-- Key 0
            IF key_in(0) = stable0 THEN
                IF unsigned(counter0) < DEBOUNCE_LIMIT THEN
                    counter0 <= std_logic_vector(unsigned(counter0) + 1);
                END IF;
            ELSE
                counter0 <= (OTHERS => '0');
            END IF;
            IF unsigned(counter0) = DEBOUNCE_LIMIT THEN
                stable0 <= key_in(0);
            END IF;

            -- Key 1
            IF key_in(1) = stable1 THEN
                IF unsigned(counter1) < DEBOUNCE_LIMIT THEN
                    counter1 <= std_logic_vector(unsigned(counter1) + 1);
                END IF;
            ELSE
                counter1 <= (OTHERS => '0');
            END IF;
            IF unsigned(counter1) = DEBOUNCE_LIMIT THEN
                stable1 <= key_in(1);
            END IF;

            -- Key 2
            IF key_in(2) = stable2 THEN
                IF unsigned(counter2) < DEBOUNCE_LIMIT THEN
                    counter2 <= std_logic_vector(unsigned(counter2) + 1);
                END IF;
            ELSE
                counter2 <= (OTHERS => '0');
            END IF;
            IF unsigned(counter2) = DEBOUNCE_LIMIT THEN
                stable2 <= key_in(2);
            END IF;

            -- Key 3
            IF key_in(3) = stable3 THEN
                IF unsigned(counter3) < DEBOUNCE_LIMIT THEN
                    counter3 <= std_logic_vector(unsigned(counter3) + 1);
                END IF;
            ELSE
                counter3 <= (OTHERS => '0');
            END IF;
            IF unsigned(counter3) = DEBOUNCE_LIMIT THEN
                stable3 <= key_in(3);
            END IF;
				
        END IF;
    END PROCESS;

    -- Assign the internal states to the outputs
    SW_debounced(9 DOWNTO 4) <= state_A;
    SW_debounced(3 DOWNTO 1) <= state_B;
    SW_debounced(0) <= state_C;
	 
	 key_debounced <= stable3 & stable2 & stable1 & stable0;

END debounce;