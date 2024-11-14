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
use work.aes128_lib.all;

entity AES128 is
    port ( CLK      : in std_logic;
           RST      : in std_logic;
           START    : in std_logic;
           DIN      : in std_logic_vector (127 downto 0);
           KEY_IN   : in std_logic_vector(127 downto 0);
           CIPHER   : in std_logic;
           DOUT     : out std_logic_vector (127 downto 0);
           FINISH   : out std_logic);
end AES128;

architecture Behavioral of AES128 is
    signal status_array : block_4x4_array;
    signal current_state, next_state : fsm_type;
    signal current_phase : aes_phase_type;
    signal round_counter : integer := 0;
    signal expanded_key : std_logic_vector(1407 downto 0); 
    signal key_w : std_logic_vector(127 downto 0);
    
begin
    ---------------------------------------------------------------------------
    -- PROCESS
    -- Description : AES FSM state transitions
    ---------------------------------------------------------------------------
    process(clk)
        begin
            if(rst = '1') then
                current_state <= IDLE;
            elsif rising_edge(clk) then
                current_state <= next_state;
            end if;
    end process;
    
    ---------------------------------------------------------------------------
    -- PROCESS
    -- Description : AES FSM state handler
    ---------------------------------------------------------------------------
    process(current_state, start)
        begin
            case current_state is
                when IDLE =>
                    finish <= '0';
                    round_counter <= 0;
                    status_array <= (others => (others => (others => '0')));
                    dout <= (others => '0');
                    
                    if (start = '1') then
                        if (CIPHER = '1') then
                            current_phase <= CIPHER_PHASE;
                        elsif (CIPHER = '0') then
                            current_phase <= DECIPHER_PHASE;
                        end if;
                        next_state <= LOAD;
                        expanded_key <= key_expansion(key_in);
                        
                    else
                        next_state <= IDLE;
                    end if;
    
                when LOAD =>
                    if (current_phase = CIPHER_PHASE) then
                        key_w <= expanded_key(1407 downto 1280);    
                        status_array <= addroundkey_f(vector_to_matrix(din), expanded_key(1407 downto 1280));  
                        next_state <= SUBBYTES; 
         
                    elsif (current_phase = DECIPHER_PHASE) then
                        key_w <= expanded_key(127 downto 0);
                        status_array <= addroundkey_f(vector_to_matrix(din), expanded_key(127 downto 0)); 
                        next_state <= SHIFTROWS;
                        
                    end if;
                    
                when SUBBYTES =>
                    status_array <= subbytes_f(status_array, current_phase);
                    if(current_phase = CIPHER_PHASE) then
                        round_counter <= round_counter + 1;
                        key_w <= expanded_key(1407 - 128*(round_counter+1) downto 1280 - 128*(round_counter+1));
                        next_state <= SHIFTROWS;
                        
                    elsif(current_phase = DECIPHER_PHASE) then        
                        next_state <= ADDROUNDKEY;
                        
                    end if;
        
                when SHIFTROWS =>
                    status_array <= shiftrows_f(status_array, current_phase);
                    if(current_phase = CIPHER_PHASE) then
                        if (round_counter < Nr) then
                           next_state <= MIXCOLUMNS;
                        else 
                           next_state <= ADDROUNDKEY;
                        end if;
                        
                    elsif(current_phase = DECIPHER_PHASE) then
                        round_counter <= round_counter + 1;
                        key_w <= expanded_key(127+128*(round_counter+1) downto 128*(round_counter+1));
                        next_state <= SUBBYTES;
                        
                    end if;
                    
                when MIXCOLUMNS =>
                    status_array <= mixcolumns_f(status_array, current_phase);
                    if(current_phase = CIPHER_PHASE) then
                           next_state <= ADDROUNDKEY;
                    elsif(current_phase = DECIPHER_PHASE) then
                           next_state <= SHIFTROWS;
                    end if;
                   
                when ADDROUNDKEY =>
                    status_array <= addroundkey_f(status_array, key_w);               
                    if (round_counter < Nr ) then
                        if(current_phase = CIPHER_PHASE) then
                                next_state <= SUBBYTES; 
                        elsif(current_phase = DECIPHER_PHASE) then
                               next_state <= MIXCOLUMNS;
                        end if;
                    else 
                        next_state <= DONE;
                    end if;
                    
                when DONE =>
                    dout <= matrix_to_vector(status_array);
                    key_w <= (others => '0');
                    expanded_key <= (others => '0');
                    finish <= '1';
                    next_state <= IDLE;
        
                when others =>
                    next_state <= IDLE;
            end case;    
    end process;
end Behavioral;
