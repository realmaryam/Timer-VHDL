----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/24/2022 11:11:16 PM
-- Design Name: 
-- Module Name: Timer_tb - Behavioral
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

entity Timer_tb is
--  Port ( );
end Timer_tb;

architecture Behavioral of Timer_tb is
    component Timer is
    Port ( clk, reset : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (4 downto 0);
           DATA : inout STD_LOGIC_VECTOR (15 downto 0);
           wr_rd : in STD_LOGIC;
           enable : in STD_LOGIC;
           PWM : out STD_LOGIC;
           cnt : out STD_LOGIC_VECTOR (15 downto 0) 
          );
    end component;
--------------------------------------------------------------------------------------
-- signals
    signal   clk, reset :  STD_LOGIC ;
    signal   A :  STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal   DATA :  STD_LOGIC_VECTOR (15 downto 0) := (others => 'Z');
    signal   wr_rd :  STD_LOGIC;
    signal   enable :  STD_LOGIC;
    signal   PWM :  STD_LOGIC;
    signal   cnt :  STD_LOGIC_VECTOR (15 downto 0) ;
    
    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin

--------------------------------------------------------------------------------------

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
-------------------------------------------------------------------------------------
process 
begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait for clk_period;
	enable <= '1';
	wr_rd <= '1';

    A <= "00000";
    DATA <= std_logic_vector(to_unsigned(5,16));        -- prescaler = 5
    wait for clk_period;
    
    A <= "00001";
    DATA <= std_logic_vector(to_unsigned(0,16));        -- cnt = 0
    wait for clk_period;
    
    A <= "00010";
    DATA <= std_logic_vector(to_unsigned(3,16));        -- up counter and start=1 
    wait for clk_period;
    
    A <= "00011";
    DATA <= std_logic_vector(to_unsigned(10,16));        -- period = 10
    wait for clk_period;
    
    A <= "00100";
    DATA <= std_logic_vector(to_unsigned(2,16));        -- Duty Cycle = 2
    wait for 100 ns;
    wait for clk_period;
    enable <= '0';
    wait;
end process;

--------------------------------------------------------------------------------------
--instantiation
    timer1 : Timer
    port map (  clk => clk,
                reset => reset,
                A => A,
                DATA => DATA,
                wr_rd => wr_rd,
                enable => enable,
                PWM => PWM,
                cnt => cnt
             );

end Behavioral;
