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
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package aes128_lib is

    ---------------------------------------------------------------------------
    -- Type & constant definition
    ---------------------------------------------------------------------------
    
    type block_4x4_array is array (0 to 3, 0 to 3) of std_logic_vector(7 downto 0);
    type sbox_array is array (0 to 15, 0 to 15) of std_logic_vector(7 downto 0);
    type rcon_array is array (0 to 9) of std_logic_vector(31 downto 0) ;
    type key_word_array is array (0 to 43) of std_logic_vector(31 downto 0); -- 44 words for AES-128
    type fsm_type is (IDLE, LOAD, SUBBYTES, SHIFTROWS, MIXCOLUMNS, ADDROUNDKEY, DONE);
    type aes_phase_type is (CIPHER_PHASE, DECIPHER_PHASE);
    
    constant Nb, Nk : integer := 4;
    constant Nr : integer := 10;
    constant sbox : sbox_array := (
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
        (x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68", x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"16")  -- F
    );
    
    constant inv_sbox : sbox_array := (
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
        (x"17", x"2B", x"04", x"7E", x"BA", x"77", x"D6", x"26", x"E1", x"69", x"14", x"63", x"55", x"21", x"0C", x"7D")  -- F
);

    
    constant rcon : rcon_array := (
        x"01000000", x"02000000", x"04000000", x"08000000", x"10000000", x"20000000", x"40000000", x"80000000", x"1b000000", x"36000000"
    );

    ---------------------------------------------------------------------------
    -- Functions definition
    ---------------------------------------------------------------------------
    
    -- Used to transfer data from a 128 bits std_logic_vector to a 128 bits 4x4 bytes matrix 
    function vector_to_matrix(vector_in : std_logic_vector(127 downto 0)) return block_4x4_array;
    
    -- Used to transfer data from a 128 bits 4x4 bytes matrix to a 128 bits std_logic_vector 
    function matrix_to_vector(matrix_in : block_4x4_array) return std_logic_vector;
    
    -- Performs multiplication by 2 in GF, done with a left shift by 1 bit
    function gf_mult(a : std_logic_vector(7 downto 0)) return std_logic_vector;
    function gf_mult_09(a : std_logic_vector(7 downto 0)) return std_logic_vector;
    function gf_mult_0b(a : std_logic_vector(7 downto 0)) return std_logic_vector;
    function gf_mult_0d(a : std_logic_vector(7 downto 0)) return std_logic_vector;
    function gf_mult_0e(a : std_logic_vector(7 downto 0)) return std_logic_vector;

    
    ----------------------------------------------------
    -- AES functions 
    -- Set phase to 1 to have cipher function
    -- Set phase to 0 to have inverse cipher function
    -----------------------------------------------------
    
     -- Applies the SubBytes transformation, substituting each byte in matrix_in with a corresponding value from sbox
    function subbytes_f(matrix_in : block_4x4_array;
                        phase : aes_phase_type) 
                        return block_4x4_array;
    
    -- Applies the ShiftRows transformation, shifting rows of matrix_in
    function shiftrows_f(matrix_in : block_4x4_array;
                         phase : aes_phase_type)
                         return block_4x4_array;
    
    -- Applies the MixColumns transformation, mixing columns of matrix_in
    function mixcolumns_f(matrix_in : block_4x4_array;
                          phase : aes_phase_type) 
                          return block_4x4_array;
    
    -- Adds the round key to the state matrix by performing an XOR operation between the matrix_in and key_w
    function addroundkey_f(matrix_in  : block_4x4_array;
                           key_w      : std_logic_vector(127 downto 0)) 
                           return block_4x4_array;
    
    -- Generates round keys from the initial key 
    function key_expansion(key_in : std_logic_vector(127 downto 0)) return std_logic_vector;

    -- Rotates 24 bits to the left and 8 bits to the right
    function rotword(word : std_logic_vector(31 downto 0)) return std_logic_vector;
    
    -- Applies byte substitution using the sbox
    function subword(word : std_logic_vector(31 downto 0)) return std_logic_vector;
   

end aes128_lib;

package body aes128_lib is
    function vector_to_matrix( vector_in : std_logic_vector(127 downto 0)) return block_4x4_array is
        variable matrix_din : block_4x4_array;
    begin
        matrix_din(0,0) := vector_in(127 downto 120);
        matrix_din(1,0) := vector_in(119 downto 112);
        matrix_din(2,0) := vector_in(111 downto 104);
        matrix_din(3,0) := vector_in(103 downto 96);
        
        matrix_din(0,1) := vector_in(95 downto 88);
        matrix_din(1,1) := vector_in(87 downto 80);
        matrix_din(2,1) := vector_in(79 downto 72);
        matrix_din(3,1) := vector_in(71 downto 64);
        
        matrix_din(0,2) := vector_in(63 downto 56);
        matrix_din(1,2) := vector_in(55 downto 48);
        matrix_din(2,2) := vector_in(47 downto 40);
        matrix_din(3,2) := vector_in(39 downto 32);
        
        matrix_din(0,3) := vector_in(31 downto 24);
        matrix_din(1,3) := vector_in(23 downto 16);
        matrix_din(2,3) := vector_in(15 downto 8);
        matrix_din(3,3) := vector_in(7 downto 0);
        return matrix_din;
    end function vector_to_matrix; 
    
    
    function matrix_to_vector( matrix_in : block_4x4_array ) return std_logic_vector is
        variable vector_out : std_logic_vector(127 downto 0);
    begin
        vector_out := matrix_in(0,0) & matrix_in(1,0) & matrix_in(2,0) & matrix_in(3,0) &
                      matrix_in(0,1) & matrix_in(1,1) & matrix_in(2,1) & matrix_in(3,1) &
                      matrix_in(0,2) & matrix_in(1,2) & matrix_in(2,2) & matrix_in(3,2) &
                      matrix_in(0,3) & matrix_in(1,3) & matrix_in(2,3) & matrix_in(3,3);
        return vector_out;
    end function matrix_to_vector;
    
    
    function gf_mult(a : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        if a(7) = '1' then
            --  LSF and xor the result with 0x1b
            return (a(6 downto 0) & '0') xor "00011011";
        else
            -- LSF
            return a(6 downto 0) & '0';
        end if;
    end function;
    
    function gf_mult_09(a : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return gf_mult(gf_mult(gf_mult(a))) xor a; -- a * 8 + a
    end function;
    
    function gf_mult_0b(a : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return (gf_mult(gf_mult(gf_mult(a))) xor gf_mult(a)) xor a; -- a * 8 + a * 2 + a
    end function;
    
    function gf_mult_0d(a : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return (gf_mult(gf_mult(gf_mult(a))) xor gf_mult(gf_mult(a))) xor a; -- a * 8 + a * 4 + a
    end function;
    
    function gf_mult_0e(a : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return (gf_mult(gf_mult(gf_mult(a))) xor gf_mult(gf_mult(a))) xor gf_mult(a); -- a * 8 + a * 4 + a * 2
    end function;
    
    function subbytes_f(matrix_in : block_4x4_array;
                        phase : aes_phase_type) 
                        return block_4x4_array is
        variable matrix_out : block_4x4_array;
        variable x,y : std_logic_vector(3 downto 0);
    begin
        
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                y := matrix_in(i,j)(3 downto 0);
                x := matrix_in(i,j)(7 downto 4);
                if(phase = CIPHER_PHASE) then
                    matrix_out(i,j) := sbox(TO_INTEGER(unsigned(x)),TO_INTEGER(unsigned(y)));
                elsif(phase = DECIPHER_PHASE) then
                    matrix_out(i,j) := inv_sbox(TO_INTEGER(unsigned(x)),TO_INTEGER(unsigned(y)));
                end if;
            end loop;
        end loop;
        return matrix_out;
    end function subbytes_f;
    
    function shiftrows_f(matrix_in : block_4x4_array;
                          phase : aes_phase_type) 
                          return block_4x4_array is
        variable matrix_out : block_4x4_array;
    begin
        -- Row 0 
        matrix_out(0,0) := matrix_in(0,0);
        matrix_out(0,1) := matrix_in(0,1);
        matrix_out(0,2) := matrix_in(0,2);
        matrix_out(0,3) := matrix_in(0,3);

        -- Row 1
        if (phase = CIPHER_PHASE) then
            matrix_out(1,0) := matrix_in(1,1);
            matrix_out(1,1) := matrix_in(1,2);
            matrix_out(1,2) := matrix_in(1,3);
            matrix_out(1,3) := matrix_in(1,0);
        elsif (phase = DECIPHER_PHASE) then
            matrix_out(1,0) := matrix_in(1,3);
            matrix_out(1,1) := matrix_in(1,0);
            matrix_out(1,2) := matrix_in(1,1);
            matrix_out(1,3) := matrix_in(1,2);
        end if;

        -- Row 2
        if (phase = CIPHER_PHASE) then
            matrix_out(2,0) := matrix_in(2,2);
            matrix_out(2,1) := matrix_in(2,3);
            matrix_out(2,2) := matrix_in(2,0);
            matrix_out(2,3) := matrix_in(2,1);
        elsif (phase = DECIPHER_PHASE) then
            matrix_out(2,0) := matrix_in(2,2);
            matrix_out(2,1) := matrix_in(2,3);
            matrix_out(2,2) := matrix_in(2,0);
            matrix_out(2,3) := matrix_in(2,1);
        end if;

        -- Row 3
        if (phase = CIPHER_PHASE) then
            matrix_out(3,0) := matrix_in(3,3);
            matrix_out(3,1) := matrix_in(3,0);
            matrix_out(3,2) := matrix_in(3,1);
            matrix_out(3,3) := matrix_in(3,2);
        elsif (phase = DECIPHER_PHASE) then
            matrix_out(3,0) := matrix_in(3,1);
            matrix_out(3,1) := matrix_in(3,2);
            matrix_out(3,2) := matrix_in(3,3);
            matrix_out(3,3) := matrix_in(3,0);
        end if;
        return matrix_out;
    end function shiftrows_f;

      
    function mixcolumns_f(matrix_in : block_4x4_array;
                          phase : aes_phase_type) 
                          return block_4x4_array is
        variable matrix_out : block_4x4_array;
    begin
       for j in 0 to 3 loop
            if(phase = CIPHER_PHASE) then
                -- To multiply by 3: do (a*2 + a)
                matrix_out(0,j) := gf_mult(matrix_in(0,j)) xor (gf_mult(matrix_in(1,j)) xor matrix_in(1,j)) xor matrix_in(2,j) xor matrix_in(3,j);
                matrix_out(1,j) := matrix_in(0,j) xor gf_mult(matrix_in(1,j)) xor (gf_mult(matrix_in(2,j)) xor matrix_in(2,j)) xor matrix_in(3,j);
                matrix_out(2,j) := matrix_in(0,j) xor matrix_in(1,j) xor gf_mult(matrix_in(2,j)) xor (gf_mult(matrix_in(3,j)) xor matrix_in(3,j));
                matrix_out(3,j) := (gf_mult(matrix_in(0,j)) xor matrix_in(0,j)) xor matrix_in(1,j) xor matrix_in(2,j) xor gf_mult(matrix_in(3,j));
            elsif(phase = DECIPHER_PHASE) then
                matrix_out(0, j) := gf_mult_0e(matrix_in(0, j)) xor gf_mult_0b(matrix_in(1, j)) xor gf_mult_0d(matrix_in(2, j)) xor gf_mult_09(matrix_in(3, j));
                matrix_out(1, j) := gf_mult_09(matrix_in(0, j)) xor gf_mult_0e(matrix_in(1, j)) xor gf_mult_0b(matrix_in(2, j)) xor gf_mult_0d(matrix_in(3, j));
                matrix_out(2, j) := gf_mult_0d(matrix_in(0, j)) xor gf_mult_09(matrix_in(1, j)) xor gf_mult_0e(matrix_in(2, j)) xor gf_mult_0b(matrix_in(3, j));
                matrix_out(3, j) := gf_mult_0b(matrix_in(0, j)) xor gf_mult_0d(matrix_in(1, j)) xor gf_mult_09(matrix_in(2, j)) xor gf_mult_0e(matrix_in(3, j));
            end if;
        end loop;
        return matrix_out;
        
    end function mixcolumns_f;
    
    function addroundkey_f(matrix_in  : block_4x4_array;
                         key_w        : std_logic_vector(127 downto 0))
                         return block_4x4_array is
        variable key_w_matrix, matrix_out : block_4x4_array;
    begin
        key_w_matrix := vector_to_matrix(key_w);
        for i in 0 to 3 loop
            for j in 0 to 3 loop
                matrix_out(i,j) := matrix_in(i,j) xor key_w_matrix(i,j);
            end loop;
        end loop;
        
        return matrix_out;
    end function addroundkey_f;
    
    function key_expansion(key_in : std_logic_vector(127 downto 0)) return std_logic_vector is
        variable w : key_word_array;
        variable temp : std_logic_vector(31 downto 0);
        variable expanded_key : std_logic_vector(1407 downto 0); 

    begin
        -- Initialize the first 4 words with the initial key
        for i in 0 to 3 loop
            w(i) := key_in(127 - 32*i downto 96 - 32*i);
        end loop;

        -- Generate the remaining key words
        for i in 4 to 43 loop
            temp := w(i-1);
            if (i mod 4 = 0) then
                temp := subword(rotword(temp)) xor Rcon(i/4-1);
            end if;
            -- XOR with the word 4 positions back
            w(i) := w(i-4) xor temp;
        end loop;
    
        -- Combine the key words into a single vector
        for i in 0 to 43 loop
            expanded_key(1407 - 32*i downto 1376 - 32*i) := w(i);
        end loop;
    
        return expanded_key;
    end function;
    
    function rotword(word : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return word(23 downto 0) & word(31 downto 24);
    end function;
    
    
    function subword(word : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable sbox_return : std_logic_vector(31 downto 0);
        variable x,y : std_logic_vector(3 downto 0);

    begin
        for i in 0 to 3 loop
            y := word((i*8)+3 downto (i*8));
            x := word((i*8)+7 downto (i*8)+4);
            sbox_return((i*8)+7 downto (i*8)) := sbox(TO_INTEGER(unsigned(x)),TO_INTEGER(unsigned(y)));
        end loop; 
        return sbox_return;
    end function;

end package body aes128_lib;

