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
-- Description: AES128.vhd testbench file
--              This file is used to simulate the AES128 IP core
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY aes128_tb IS

END aes128_tb;

ARCHITECTURE Behavioral OF aes128_tb IS

    COMPONENT aes128 IS
        PORT (
            CLK : IN STD_LOGIC;
            ARST : IN STD_LOGIC;
            START : IN STD_LOGIC;
            DIN : IN STD_LOGIC_VECTOR (127 DOWNTO 0);
            KEY_IN : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
            CIPHER : IN STD_LOGIC;
            DOUT : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
            FINISH : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL clk, arst, start, cipher, finish : STD_LOGIC := '0';
    SIGNAL din, key_in, dout : STD_LOGIC_VECTOR (127 DOWNTO 0);
    CONSTANT CLK_PERIOD : TIME := 1 ns;
BEGIN

    dut : aes128
    PORT MAP(
        CLK => clk,
        ARST => arst,
        START => start,
        DIN => din,
        KEY_IN => key_in,
        CIPHER => cipher,
        DOUT => dout,
        FINISH => finish);

    ---------------------------------------------------------------------------
    -- PROCESS: CLK_PROCESS
    -- Description: Clock generation process
    ---------------------------------------------------------------------------
    CLK_PROCESS : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD/2;
        clk <= '1';
        WAIT FOR CLK_PERIOD/2;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- PROCESS: ARST_PROCESS
    -- Description: Asynchronous Reset generation process
    ---------------------------------------------------------------------------
    ARST_PROCESS : PROCESS
    BEGIN
        arst <= '1';
        WAIT FOR CLK_PERIOD * 20;
        arst <= '0';
        WAIT FOR 1000ns;

    END PROCESS;

    ---------------------------------------------------------------------------
    -- PROCESS: SIGNALS_PROCESS
    -- Description: Plain text & key generation process
    ---------------------------------------------------------------------------
    SIGNALS_PROCESS : PROCESS
    BEGIN
        -- Wait Reset
        WAIT UNTIL arst = '0';

        -- Start of 1st sequence
        -- Cipher 
        start <= '1';
        cipher <= '1';
        din <= x"00112233445566778899aabbccddeeff";
        key_in <= x"000102030405060708090a0b0c0d0e0f";
        WAIT FOR CLK_PERIOD;
        start <= '0';
        WAIT UNTIL finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        WAIT FOR CLK_PERIOD;
        WAIT FOR CLK_PERIOD;

        -- Decipher
        start <= '1';
        cipher <= '0';
        din <= x"69c4e0d86a7b0430d8cdb78070b4c55a";
        key_in <= x"000102030405060708090a0b0c0d0e0f";
        WAIT FOR CLK_PERIOD;
        start <= '0';
        WAIT UNTIL finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        WAIT FOR CLK_PERIOD;

        -- Start of 2nd sequence
        -- Cipher 
        start <= '1';
        cipher <= '1';
        din <= x"3243f6a8885a308d313198a2e0370734";
        key_in <= x"2b7e151628aed2a6abf7158809cf4f3c";
        WAIT FOR CLK_PERIOD;
        start <= '0';
        WAIT UNTIL finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        WAIT FOR CLK_PERIOD;
        WAIT FOR CLK_PERIOD;

        -- Decipher
        start <= '1';
        cipher <= '0';
        din <= x"3925841d02dc09fbdc118597196a0b32";
        key_in <= x"2b7e151628aed2a6abf7158809cf4f3c";
        WAIT FOR CLK_PERIOD;
        start <= '0';
        WAIT UNTIL finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        WAIT FOR CLK_PERIOD;

    END PROCESS;

END Behavioral;