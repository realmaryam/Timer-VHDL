----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2022 11:26:10 AM
-- Design Name: 
-- Module Name: Timer - Behavioral
-- Project Name: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Timer is
    Port ( clk, reset : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (4 downto 0);
           DATA : inout STD_LOGIC_VECTOR (15 downto 0);
           wr_rd : in STD_LOGIC;
           enable : in STD_LOGIC;
           PWM : out STD_LOGIC;
           cnt : out STD_LOGIC_VECTOR (15 downto 0)      -- COUNTER
          );
end Timer;

architecture Behavioral of Timer is
    type state_type is (idle, count, oneclock);
    type mem_2d_type is array (0 to 4) of
         std_logic_vector(15 downto 0);
    signal state_reg, state_next : state_type;
    signal array_reg : mem_2d_type;
    signal cnt_reg, cnt_next     : unsigned(15 downto 0);
    signal prescaler     : unsigned(15 downto 0);
    signal dutycycle     : unsigned(15 downto 0);
    signal period        : unsigned(15 downto 0);
    signal up_down : std_logic;
    signal start_stop : std_logic;
    signal cnt2_reg, cnt2_next : unsigned(15 downto 0);         --used for prescaler
    signal pwm_reg : std_logic;
    signal cnt_load : unsigned (15 downto 0);

    
    
begin
    process(clk, reset, enable, wr_rd)
    begin
       if reset = '1' then
            state_reg <= idle;
            cnt_reg <= (others => '0');
            cnt2_reg <= (others => '0');
           

       elsif (clk'event and clk = '1')then
             state_reg <= state_next;
             cnt_reg <= cnt_next;
             cnt2_reg <= cnt2_next;
             if enable = '1' then
                if wr_rd = '1' then
                    array_reg(to_integer(unsigned(A))) <= DATA;
                    cnt_reg <= cnt_load;
                else
                    array_reg(1) <= std_logic_vector(cnt_reg);
                    DATA <= array_reg(to_integer(unsigned(A))); 
                end if;
             else 
                DATA <= (others => 'Z');
            end if; 
        end if;
    end process;
    
    prescaler <= unsigned(array_reg(0));
    cnt_load <= unsigned(array_reg(1));
    start_stop <= array_reg(2)(0);
    up_down <= array_reg(2)(1);
    period <= unsigned(array_reg(3));
    dutycycle <= unsigned(array_reg(4));

    process(state_reg,prescaler,dutycycle,period,up_down,start_stop,cnt_reg,cnt_next,pwm_reg,cnt2_reg,cnt2_next)
    begin
        state_next <= state_reg;
        cnt_next <= cnt_reg;
        cnt2_next <= cnt2_reg;
        if cnt_reg <= (dutycycle)-1 then
            pwm_reg <= '1';
        else
            pwm_reg <= '0';
        end if; 
        case state_reg is
            when idle =>
                if start_stop ='1' then
                    state_next <= count;
                end if;
            
            when count =>
                if start_stop = '0' then
                    state_next <= idle;
                else
                    if up_down = '1' then
                        cnt2_next <= cnt2_reg + 1;
                        if cnt2_reg = prescaler-1 then
                            state_next <= oneclock;
                            cnt2_next <= (others => '0');
                        end if; 
                    else
                        cnt2_next <= cnt2_reg - 1;
                        if cnt2_reg = to_unsigned(1,16) then
                            state_next <= oneclock;
                            cnt2_next <= prescaler;
                        end if; 
                    end if;
                    
                end if;
                
            when oneclock =>
                if start_stop = '0' then
                    state_next <= idle;
                else
                    if up_down = '1' then
                        cnt2_next <= cnt2_reg + 1;
                        cnt_next <= cnt_reg + 1;
                        if cnt_reg >= period-1 then
                            cnt_next <= (others => '0');
                        end if;
                    else
                        cnt_next <= cnt_reg - 1;
                        cnt2_next <= cnt2_reg - 1;
                        if cnt_reg <= to_unsigned(1,16) then
                            cnt_next <= period;
                        end if;
                    end if;
                    state_next <= count;
                end if;

        end case;
    end process;
    PWM <= pwm_reg;
    cnt <= std_logic_vector(cnt_reg);
    

end Behavioral;
