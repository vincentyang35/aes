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
-- Description: AES128 library for the AES128 IP core
--              This file contains the AES encryption and decryption functions 
--              used in the AES128 IP core
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

PACKAGE aes128_lib IS

    ---------------------------------------------------------------------------
    -- Type & constant definition
    ---------------------------------------------------------------------------

    TYPE block_4x4_array IS ARRAY (0 TO 3, 0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE sbox_array IS ARRAY (0 TO 15, 0 TO 15) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE rcon_array IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE key_word_array IS ARRAY (0 TO 43) OF STD_LOGIC_VECTOR(31 DOWNTO 0); -- 44 words for AES-128
    TYPE fsm_type IS (IDLE, LOAD, SUBBYTES, SHIFTROWS, MIXCOLUMNS, ADDROUNDKEY, DONE);
    TYPE aes_phase_type IS (CIPHER_PHASE, DECIPHER_PHASE);

    CONSTANT Nb, Nk : INTEGER := 4;
    CONSTANT Nr : INTEGER := 10;
    CONSTANT sbox : sbox_array := (
        --     0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        (x"63", x"7C", x"77", x"7B", x"F2", x"6B", x"6F", x"C5", x"30", x"01", x"67", x"2B", x"FE", x"D7", x"AB", x"76"), -- 0
        (x"CA", x"82", x"C9", x"7D", x"FA", x"59", x"47", x"F0", x"AD", x"D4", x"A2", x"AF", x"9C", x"A4", x"72", x"C0"), -- 1
        (x"B7", x"FD", x"93", x"26", x"36", x"3F", x"F7", x"CC", x"34", x"A5", x"E5", x"F1", x"71", x"D8", x"31", x"15"), -- 2
        (x"04", x"C7", x"23", x"C3", x"18", x"96", x"05", x"9A", x"07", x"12", x"80", x"E2", x"EB", x"27", x"B2", x"75"), -- 3
        (x"09", x"83", x"2C", x"1A", x"1B", x"6E", x"5A", x"A0", x"52", x"3B", x"D6", x"B3", x"29", x"E3", x"2F", x"84"), -- 4
        (x"53", x"D1", x"00", x"ED", x"20", x"FC", x"B1", x"5B", x"6A", x"CB", x"BE", x"39", x"4A", x"4C", x"58", x"CF"), -- 5
        (x"D0", x"EF", x"AA", x"FB", x"43", x"4D", x"33", x"85", x"45", x"F9", x"02", x"7F", x"50", x"3C", x"9F", x"A8"), -- 6
        (x"51", x"A3", x"40", x"8F", x"92", x"9D", x"38", x"F5", x"BC", x"B6", x"DA", x"21", x"10", x"FF", x"F3", x"D2"), -- 7
        (x"CD", x"0C", x"13", x"EC", x"5F", x"97", x"44", x"17", x"C4", x"A7", x"7E", x"3D", x"64", x"5D", x"19", x"73"), -- 8
        (x"60", x"81", x"4F", x"DC", x"22", x"2A", x"90", x"88", x"46", x"EE", x"B8", x"14", x"DE", x"5E", x"0B", x"DB"), -- 9
        (x"E0", x"32", x"3A", x"0A", x"49", x"06", x"24", x"5C", x"C2", x"D3", x"AC", x"62", x"91", x"95", x"E4", x"79"), -- A
        (x"E7", x"C8", x"37", x"6D", x"8D", x"D5", x"4E", x"A9", x"6C", x"56", x"F4", x"EA", x"65", x"7A", x"AE", x"08"), -- B
        (x"BA", x"78", x"25", x"2E", x"1C", x"A6", x"B4", x"C6", x"E8", x"DD", x"74", x"1F", x"4B", x"BD", x"8B", x"8A"), -- C
        (x"70", x"3E", x"B5", x"66", x"48", x"03", x"F6", x"0E", x"61", x"35", x"57", x"B9", x"86", x"C1", x"1D", x"9E"), -- D
        (x"E1", x"F8", x"98", x"11", x"69", x"D9", x"8E", x"94", x"9B", x"1E", x"87", x"E9", x"CE", x"55", x"28", x"DF"), -- E
        (x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68", x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"16") -- F
    );

    CONSTANT inv_sbox : sbox_array := (
        --     0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        (x"52", x"09", x"6A", x"D5", x"30", x"36", x"A5", x"38", x"BF", x"40", x"A3", x"9E", x"81", x"F3", x"D7", x"FB"), -- 0
        (x"7C", x"E3", x"39", x"82", x"9B", x"2F", x"FF", x"87", x"34", x"8E", x"43", x"44", x"C4", x"DE", x"E9", x"CB"), -- 1
        (x"54", x"7B", x"94", x"32", x"A6", x"C2", x"23", x"3D", x"EE", x"4C", x"95", x"0B", x"42", x"FA", x"C3", x"4E"), -- 2
        (x"08", x"2E", x"A1", x"66", x"28", x"D9", x"24", x"B2", x"76", x"5B", x"A2", x"49", x"6D", x"8B", x"D1", x"25"), -- 3
        (x"72", x"F8", x"F6", x"64", x"86", x"68", x"98", x"16", x"D4", x"A4", x"5C", x"CC", x"5D", x"65", x"B6", x"92"), -- 4
        (x"6C", x"70", x"48", x"50", x"FD", x"ED", x"B9", x"DA", x"5E", x"15", x"46", x"57", x"A7", x"8D", x"9D", x"84"), -- 5
        (x"90", x"D8", x"AB", x"00", x"8C", x"BC", x"D3", x"0A", x"F7", x"E4", x"58", x"05", x"B8", x"B3", x"45", x"06"), -- 6
        (x"D0", x"2C", x"1E", x"8F", x"CA", x"3F", x"0F", x"02", x"C1", x"AF", x"BD", x"03", x"01", x"13", x"8A", x"6B"), -- 7
        (x"3A", x"91", x"11", x"41", x"4F", x"67", x"DC", x"EA", x"97", x"F2", x"CF", x"CE", x"F0", x"B4", x"E6", x"73"), -- 8
        (x"96", x"AC", x"74", x"22", x"E7", x"AD", x"35", x"85", x"E2", x"F9", x"37", x"E8", x"1C", x"75", x"DF", x"6E"), -- 9
        (x"47", x"F1", x"1A", x"71", x"1D", x"29", x"C5", x"89", x"6F", x"B7", x"62", x"0E", x"AA", x"18", x"BE", x"1B"), -- A
        (x"FC", x"56", x"3E", x"4B", x"C6", x"D2", x"79", x"20", x"9A", x"DB", x"C0", x"FE", x"78", x"CD", x"5A", x"F4"), -- B
        (x"1F", x"DD", x"A8", x"33", x"88", x"07", x"C7", x"31", x"B1", x"12", x"10", x"59", x"27", x"80", x"EC", x"5F"), -- C
        (x"60", x"51", x"7F", x"A9", x"19", x"B5", x"4A", x"0D", x"2D", x"E5", x"7A", x"9F", x"93", x"C9", x"9C", x"EF"), -- D
        (x"A0", x"E0", x"3B", x"4D", x"AE", x"2A", x"F5", x"B0", x"C8", x"EB", x"BB", x"3C", x"83", x"53", x"99", x"61"), -- E
        (x"17", x"2B", x"04", x"7E", x"BA", x"77", x"D6", x"26", x"E1", x"69", x"14", x"63", x"55", x"21", x"0C", x"7D") -- F
    );
    CONSTANT rcon : rcon_array := (
        x"01000000", x"02000000", x"04000000", x"08000000", x"10000000", x"20000000", x"40000000", x"80000000", x"1b000000", x"36000000"
    );

    ---------------------------------------------------------------------------
    -- Functions definition
    ---------------------------------------------------------------------------

    -- Used to transfer data from a 128 bits std_logic_vector to a 128 bits 4x4 bytes matrix 
    FUNCTION vector_to_matrix(vector_in : STD_LOGIC_VECTOR(127 DOWNTO 0)) RETURN block_4x4_array;

    -- Used to transfer data from a 128 bits 4x4 bytes matrix to a 128 bits std_logic_vector 
    FUNCTION matrix_to_vector(matrix_in : block_4x4_array) RETURN STD_LOGIC_VECTOR;

    -- Performs multiplication by 2 in GF, done with a left shift by 1 bit
    FUNCTION gf_mult(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;
    FUNCTION gf_mult_09(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;
    FUNCTION gf_mult_0b(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;
    FUNCTION gf_mult_0d(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;
    FUNCTION gf_mult_0e(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;
    ----------------------------------------------------
    -- AES functions 
    -- Set phase to 1 to have cipher function
    -- Set phase to 0 to have inverse cipher function
    -----------------------------------------------------

    -- Applies the SubBytes transformation, substituting each byte in matrix_in with a corresponding value from sbox
    FUNCTION subbytes_f(matrix_in : block_4x4_array;
        phase : aes_phase_type
    ) RETURN block_4x4_array;

    -- Applies the ShiftRows transformation, shifting rows of matrix_in
    FUNCTION shiftrows_f(matrix_in : block_4x4_array;
        phase : aes_phase_type
    ) RETURN block_4x4_array;

    -- Applies the MixColumns transformation, mixing columns of matrix_in
    FUNCTION mixcolumns_f(matrix_in : block_4x4_array;
        phase : aes_phase_type
    ) RETURN block_4x4_array;

    -- Adds the round key to the state matrix by performing an XOR operation between the matrix_in and key_w
    FUNCTION addroundkey_f(matrix_in : block_4x4_array;
        key_w : STD_LOGIC_VECTOR(127 DOWNTO 0)
    ) RETURN block_4x4_array;

    -- Generates round keys from the initial key 
    FUNCTION key_expansion(key_in : STD_LOGIC_VECTOR(127 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;

    -- Rotates 24 bits to the left and 8 bits to the right
    FUNCTION rotword(word : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;

    -- Applies byte substitution using the sbox
    FUNCTION subword(word : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR;
END aes128_lib;

PACKAGE BODY aes128_lib IS
    FUNCTION vector_to_matrix(vector_in : STD_LOGIC_VECTOR(127 DOWNTO 0)) RETURN block_4x4_array IS
        VARIABLE matrix_din : block_4x4_array;
    BEGIN
        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                matrix_din(i, j) := vector_in(127 - 8 * (i + 4 * j) DOWNTO 120 - 8 * (i + 4 * j));
            END LOOP;
        END LOOP;
        RETURN matrix_din;
    END FUNCTION vector_to_matrix;

    FUNCTION matrix_to_vector(matrix_in : block_4x4_array) RETURN STD_LOGIC_VECTOR IS
        VARIABLE vector_out : STD_LOGIC_VECTOR(127 DOWNTO 0);
    BEGIN
        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                vector_out(127 - 8 * (i + 4 * j) DOWNTO 120 - 8 * (i + 4 * j)) := matrix_in(i, j);
            END LOOP;
        END LOOP;
        RETURN vector_out;
    END FUNCTION matrix_to_vector;

    FUNCTION gf_mult(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        IF a(7) = '1' THEN
            --  LSF and xor the result with 0x1b
            RETURN (a(6 DOWNTO 0) & '0') XOR "00011011";
        ELSE
            -- LSF
            RETURN a(6 DOWNTO 0) & '0';
        END IF;
    END FUNCTION;

    FUNCTION gf_mult_09(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN gf_mult(gf_mult(gf_mult(a))) XOR a; -- a * 8 + a
    END FUNCTION;

    FUNCTION gf_mult_0b(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN (gf_mult(gf_mult(gf_mult(a))) XOR gf_mult(a)) XOR a; -- a * 8 + a * 2 + a
    END FUNCTION;

    FUNCTION gf_mult_0d(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN (gf_mult(gf_mult(gf_mult(a))) XOR gf_mult(gf_mult(a))) XOR a; -- a * 8 + a * 4 + a
    END FUNCTION;

    FUNCTION gf_mult_0e(a : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN (gf_mult(gf_mult(gf_mult(a))) XOR gf_mult(gf_mult(a))) XOR gf_mult(a); -- a * 8 + a * 4 + a * 2
    END FUNCTION;

    FUNCTION subbytes_f(matrix_in : block_4x4_array;
        phase : aes_phase_type)
        RETURN block_4x4_array IS
        VARIABLE matrix_out : block_4x4_array;
    BEGIN

        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                IF (phase = CIPHER_PHASE) THEN
                    matrix_out(i, j) := sbox(TO_INTEGER(unsigned(matrix_in(i, j)(7 DOWNTO 4))), -- x
                    TO_INTEGER(unsigned(matrix_in(i, j)(3 DOWNTO 0)))); -- y
                ELSIF (phase = DECIPHER_PHASE) THEN
                    matrix_out(i, j) := inv_sbox(TO_INTEGER(unsigned(matrix_in(i, j)(7 DOWNTO 4))), -- x
                    TO_INTEGER(unsigned(matrix_in(i, j)(3 DOWNTO 0)))); -- y
                END IF;
            END LOOP;
        END LOOP;

        RETURN matrix_out;
    END FUNCTION subbytes_f;

    FUNCTION shiftrows_f(matrix_in : block_4x4_array;
        phase : aes_phase_type)
        RETURN block_4x4_array IS
        VARIABLE matrix_out : block_4x4_array;
    BEGIN
        FOR j IN 0 TO 3 LOOP
            IF (phase = CIPHER_PHASE) THEN
                matrix_out(0, j) := matrix_in(0, j);
                matrix_out(1, j) := matrix_in(1, (j + 1) MOD 4);
                matrix_out(2, j) := matrix_in(2, (j + 2) MOD 4);
                matrix_out(3, j) := matrix_in(3, (j + 3) MOD 4);
            ELSIF (phase = DECIPHER_PHASE) THEN
                matrix_out(0, j) := matrix_in(0, j);
                matrix_out(1, j) := matrix_in(1, (j + 3) MOD 4);
                matrix_out(2, j) := matrix_in(2, (j + 2) MOD 4);
                matrix_out(3, j) := matrix_in(3, (j + 1) MOD 4);
            END IF;
        END LOOP;
        RETURN matrix_out;
    END FUNCTION shiftrows_f;
    FUNCTION mixcolumns_f(matrix_in : block_4x4_array;
        phase : aes_phase_type)
        RETURN block_4x4_array IS
        VARIABLE matrix_out : block_4x4_array;
    BEGIN
        FOR j IN 0 TO 3 LOOP
            IF (phase = CIPHER_PHASE) THEN
                -- To multiply by 3: do (a*2 + a)
                matrix_out(0, j) := gf_mult(matrix_in(0, j)) XOR (gf_mult(matrix_in(1, j)) XOR matrix_in(1, j)) XOR matrix_in(2, j) XOR matrix_in(3, j);
                matrix_out(1, j) := matrix_in(0, j) XOR gf_mult(matrix_in(1, j)) XOR (gf_mult(matrix_in(2, j)) XOR matrix_in(2, j)) XOR matrix_in(3, j);
                matrix_out(2, j) := matrix_in(0, j) XOR matrix_in(1, j) XOR gf_mult(matrix_in(2, j)) XOR (gf_mult(matrix_in(3, j)) XOR matrix_in(3, j));
                matrix_out(3, j) := (gf_mult(matrix_in(0, j)) XOR matrix_in(0, j)) XOR matrix_in(1, j) XOR matrix_in(2, j) XOR gf_mult(matrix_in(3, j));
            ELSIF (phase = DECIPHER_PHASE) THEN
                matrix_out(0, j) := gf_mult_0e(matrix_in(0, j)) XOR gf_mult_0b(matrix_in(1, j)) XOR gf_mult_0d(matrix_in(2, j)) XOR gf_mult_09(matrix_in(3, j));
                matrix_out(1, j) := gf_mult_09(matrix_in(0, j)) XOR gf_mult_0e(matrix_in(1, j)) XOR gf_mult_0b(matrix_in(2, j)) XOR gf_mult_0d(matrix_in(3, j));
                matrix_out(2, j) := gf_mult_0d(matrix_in(0, j)) XOR gf_mult_09(matrix_in(1, j)) XOR gf_mult_0e(matrix_in(2, j)) XOR gf_mult_0b(matrix_in(3, j));
                matrix_out(3, j) := gf_mult_0b(matrix_in(0, j)) XOR gf_mult_0d(matrix_in(1, j)) XOR gf_mult_09(matrix_in(2, j)) XOR gf_mult_0e(matrix_in(3, j));
            END IF;
        END LOOP;
        RETURN matrix_out;

    END FUNCTION mixcolumns_f;

    FUNCTION addroundkey_f(matrix_in : block_4x4_array;
        key_w : STD_LOGIC_VECTOR(127 DOWNTO 0))
        RETURN block_4x4_array IS
        VARIABLE key_w_matrix, matrix_out : block_4x4_array;
    BEGIN
        key_w_matrix := vector_to_matrix(key_w);
        FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                matrix_out(i, j) := matrix_in(i, j) XOR key_w_matrix(i, j);
            END LOOP;
        END LOOP;

        RETURN matrix_out;
    END FUNCTION addroundkey_f;

    FUNCTION key_expansion(key_in : STD_LOGIC_VECTOR(127 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE w : key_word_array;
        VARIABLE temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- expanded_key size for:
        -- AES128 : 44 words -> 176 bytes -> 1408 bits
        -- AES192 : 52 words -> 208 bytes -> 1664 bits
        -- AES256 : 60 words -> 240 bytes -> 1920 bits
        VARIABLE expanded_key : STD_LOGIC_VECTOR((Nb * (Nr + 1) * 32) - 1 DOWNTO 0);

    BEGIN
        -- Initialize the first 4 words with the initial key
        FOR i IN 0 TO Nk - 1 LOOP
            w(i) := key_in(127 - 32 * i DOWNTO 96 - 32 * i);
        END LOOP;

        -- Generate the remaining key words
        FOR i IN Nk TO 43 LOOP
            temp := w(i - 1);
            IF (i MOD Nk = 0) THEN
                temp := subword(rotword(temp)) XOR Rcon(i/Nk - 1);
            END IF;
            -- TODO: Add ELIF Nk > 6 & i mod Nk = 4 for AES192 and AES256

            -- XOR with the word Nk positions back
            w(i) := w(i - Nk) XOR temp;
        END LOOP;

        -- Combine the key words into a single vector
        FOR i IN 0 TO 43 LOOP
            expanded_key(1407 - 32 * i DOWNTO 1376 - 32 * i) := w(i);
        END LOOP;

        RETURN expanded_key;
    END FUNCTION;

    FUNCTION rotword(word : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN word(23 DOWNTO 0) & word(31 DOWNTO 24);
    END FUNCTION;

    FUNCTION subword(word : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE sbox_return : STD_LOGIC_VECTOR(31 DOWNTO 0);

    BEGIN
        FOR i IN 0 TO 3 LOOP
            sbox_return((i * 8) + 7 DOWNTO (i * 8)) := sbox(TO_INTEGER(unsigned(word((i * 8) + 7 DOWNTO (i * 8) + 4))), -- x
            TO_INTEGER(unsigned(word((i * 8) + 3 DOWNTO (i * 8))))); -- y
        END LOOP;
        RETURN sbox_return;
    END FUNCTION;

END PACKAGE BODY aes128_lib;