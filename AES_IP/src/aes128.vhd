----------------------------------------------------------------------------------
-- Company: ELSYS Design
-- Engineer: Vincent YANG
-- 
-- Create Date: 16.10.2024 14:49:07
-- Design Name: aes128
-- Module Name: aes128 - Behavioral
-- Project Name: aes_test
-- Target Devices: 
-- Tool Versions: 
-- Description: A simple AES128 encryption/decryption IP core
--              This file is the top level file for the AES128 IP core
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.aes128_lib.ALL;

ENTITY AES128 IS
    PORT (
        CLK : IN STD_LOGIC;
        ARST : IN STD_LOGIC;
        START : IN STD_LOGIC;
        DIN : IN STD_LOGIC_VECTOR (127 DOWNTO 0);
        KEY_IN : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
        CIPHER : IN STD_LOGIC;
        DOUT : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
        FINISH : OUT STD_LOGIC);
END AES128;

ARCHITECTURE Behavioral OF AES128 IS
    SIGNAL status_array : block_4x4_array;
    SIGNAL current_state, next_state : fsm_type;
    SIGNAL current_phase : aes_phase_type;
    SIGNAL round_counter : INTEGER := 0;
    SIGNAL expanded_key : STD_LOGIC_VECTOR(1407 DOWNTO 0);
    SIGNAL key_w : STD_LOGIC_VECTOR(127 DOWNTO 0);

BEGIN
    ---------------------------------------------------------------------------
    -- PROCESS
    -- Description : AES FSM state transitions
    ---------------------------------------------------------------------------
    PROCESS (clk, arst)
    BEGIN
        IF (arst = '1') THEN
            current_state <= IDLE;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- PROCESS
    -- Description : AES FSM state handler
    ---------------------------------------------------------------------------
    PROCESS (current_state, start)
    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                finish <= '0';
                round_counter <= 0;
                status_array <= (OTHERS => (OTHERS => (OTHERS => '0')));
                dout <= (OTHERS => '0');

                IF (start = '1') THEN
                    IF (CIPHER = '1') THEN
                        current_phase <= CIPHER_PHASE;
                    ELSIF (CIPHER = '0') THEN
                        current_phase <= DECIPHER_PHASE;
                    END IF;
                    next_state <= LOAD;
                    expanded_key <= key_expansion(key_in);

                ELSE
                    next_state <= IDLE;
                END IF;

            WHEN LOAD =>
                IF (current_phase = CIPHER_PHASE) THEN
                    key_w <= expanded_key(1407 DOWNTO 1280);
                    status_array <= addroundkey_f(vector_to_matrix(din), expanded_key(1407 DOWNTO 1280));
                    next_state <= SUBBYTES;

                ELSIF (current_phase = DECIPHER_PHASE) THEN
                    key_w <= expanded_key(127 DOWNTO 0);
                    status_array <= addroundkey_f(vector_to_matrix(din), expanded_key(127 DOWNTO 0));
                    next_state <= SHIFTROWS;

                END IF;

            WHEN SUBBYTES =>
                status_array <= subbytes_f(status_array, current_phase);
                IF (current_phase = CIPHER_PHASE) THEN
                    round_counter <= round_counter + 1;
                    key_w <= expanded_key(1407 - 128 * (round_counter + 1) DOWNTO 1280 - 128 * (round_counter + 1));
                    next_state <= SHIFTROWS;

                ELSIF (current_phase = DECIPHER_PHASE) THEN
                    next_state <= ADDROUNDKEY;

                END IF;

            WHEN SHIFTROWS =>
                status_array <= shiftrows_f(status_array, current_phase);
                IF (current_phase = CIPHER_PHASE) THEN
                    IF (round_counter < Nr) THEN
                        next_state <= MIXCOLUMNS;
                    ELSE
                        next_state <= ADDROUNDKEY;
                    END IF;

                ELSIF (current_phase = DECIPHER_PHASE) THEN
                    round_counter <= round_counter + 1;
                    key_w <= expanded_key(127 + 128 * (round_counter + 1) DOWNTO 128 * (round_counter + 1));
                    next_state <= SUBBYTES;

                END IF;

            WHEN MIXCOLUMNS =>
                status_array <= mixcolumns_f(status_array, current_phase);
                IF (current_phase = CIPHER_PHASE) THEN
                    next_state <= ADDROUNDKEY;
                ELSIF (current_phase = DECIPHER_PHASE) THEN
                    next_state <= SHIFTROWS;
                END IF;

            WHEN ADDROUNDKEY =>
                status_array <= addroundkey_f(status_array, key_w);
                IF (round_counter < Nr) THEN
                    IF (current_phase = CIPHER_PHASE) THEN
                        next_state <= SUBBYTES;
                    ELSIF (current_phase = DECIPHER_PHASE) THEN
                        next_state <= MIXCOLUMNS;
                    END IF;
                ELSE
                    next_state <= DONE;
                END IF;

            WHEN DONE =>
                dout <= matrix_to_vector(status_array);
                key_w <= (OTHERS => '0');
                expanded_key <= (OTHERS => '0');
                finish <= '1';
                next_state <= IDLE;

            WHEN OTHERS =>
                next_state <= IDLE;
        END CASE;
    END PROCESS;
END Behavioral;