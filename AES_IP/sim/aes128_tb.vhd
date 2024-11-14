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

entity aes128_tb is
--  Port ( );
end aes128_tb;

architecture Behavioral of aes128_tb is

    component aes128 is  
         port ( CLK      : in std_logic;
                RST      : in std_logic;
                START    : in std_logic;
                DIN      : in std_logic_vector (127 downto 0);
                KEY_IN   : in std_logic_vector(127 downto 0);
                CIPHER   : in std_logic;
                DOUT     : out std_logic_vector (127 downto 0);
                FINISH   : out std_logic);
    end component;
    
    signal clk, rst, start, cipher, finish : std_logic:= '0';
    signal din, key_in, dout : std_logic_vector (127 downto 0);
    constant CLK_PERIOD : time := 1 ns;
begin
    
    dut : aes128 
          port map ( CLK => clk, 
                     RST => rst, 
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
    CLK_PROCESS : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    ---------------------------------------------------------------------------
    -- PROCESS: RST_PROCESS
    -- Description: Reset generation process
    ---------------------------------------------------------------------------
    RST_PROCESS : process
    begin
        rst <= '1';
        wait for CLK_PERIOD*20;
        rst <= '0';
        wait for 1000ns;
    
    end process;
    
    ---------------------------------------------------------------------------
    -- PROCESS: SIGNALS_PROCESS
    -- Description: Plain text & key generation process
    ---------------------------------------------------------------------------
    SIGNALS_PROCESS : process
    begin
        -- Wait Reset
        wait until rst = '0';
        
        -- Start of 1st sequence
        -- Cipher 
        start <= '1';
        cipher <= '1';
        din <= x"00112233445566778899aabbccddeeff";
        key_in <= x"000102030405060708090a0b0c0d0e0f";
        wait for CLK_PERIOD;
        start <= '0';
        wait until finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;
        
        -- Decipher
        start <= '1';
        cipher <= '0';
        din <= x"69c4e0d86a7b0430d8cdb78070b4c55a";
        key_in <= x"000102030405060708090a0b0c0d0e0f";
        wait for CLK_PERIOD;
        start <= '0';
        wait until finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        wait for CLK_PERIOD;
        
        -- Start of 2nd sequence
        -- Cipher 
        start <= '1';
        cipher <= '1';
        din <= x"3243f6a8885a308d313198a2e0370734";
        key_in <= x"2b7e151628aed2a6abf7158809cf4f3c";
        wait for CLK_PERIOD;
        start <= '0';
        wait until finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;
        
        -- Decipher
        start <= '1';
        cipher <= '0';
        din <= x"3925841d02dc09fbdc118597196a0b32";
        key_in <= x"2b7e151628aed2a6abf7158809cf4f3c";
        wait for CLK_PERIOD;
        start <= '0';
        wait until finish = '1';
        din <= x"00000000000000000000000000000000";
        key_in <= x"00000000000000000000000000000000";
        wait for CLK_PERIOD;

    end process;

end Behavioral;
