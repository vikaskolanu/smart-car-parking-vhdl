-- ==============================================================================
-- Project: Automated Smart Parking Controller
-- File: car_parking_sys.vhd
-- Description: FSM-based parking access controller with credential validation,
--              timeout counters, entry/exit sensor synchronization, and
--              status indicators.
-- ==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity car_parking_sys is
    port (
        clk            : in  std_logic;
        reset          : in  std_logic; -- Active-low reset
        outside_sensor : in  std_logic; -- Vehicle detected at entry gate
        inside_sensor  : in  std_logic; -- Vehicle detected inside parking lot
        password       : in  std_logic_vector(3 downto 0); -- 4-bit passcode input
        red_light      : out std_logic; -- Access denied indicator
        green_light    : out std_logic  -- Access granted / barrier open indicator
    );
end entity car_parking_sys;

architecture logic of car_parking_sys is
    type state is (idle, waitting, correct_password, wrong_password, stop);
    signal current_state, next_state : state;
    signal counter : unsigned(32 downto 0);
begin

    -- State Register Process
    process(clk, reset) is 
    begin
        if reset = '0' then
            current_state <= idle;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process; 

    -- Timeout Counter Process
    process(clk, reset) is 
    begin
        if reset = '0' then 
            counter <= (others => '0');
        elsif rising_edge(clk) then
            if current_state = idle then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Next State Combinational Logic
    process(outside_sensor, inside_sensor, password, current_state, counter) is
    begin
        case current_state is 
            when idle =>
                if outside_sensor = '1' then 
                    next_state <= waitting;
                else 
                    next_state <= idle;
                end if;

            when waitting =>  
                if counter < x"FFFFF" then 
                    if password = "0111" then 
                        next_state <= correct_password;
                    else 
                        next_state <= wrong_password;
                    end if;
                else 
                    next_state <= stop;
                end if;

            when wrong_password =>
                if counter < x"11111" then  
                    if password = "0111" then 
                        next_state <= correct_password;
                    else 
                        next_state <= wrong_password;
                    end if;
                else 
                    next_state <= stop;
                end if;

            when correct_password =>
                if inside_sensor = '1' then 
                    next_state <= stop;
                else 
                    next_state <= correct_password;
                end if;

            when stop =>
                next_state <= idle;

            when others =>
                next_state <= idle;
        end case;
    end process;

    -- Output Logic (Moore Model)
    process(current_state) is
    begin 
        case current_state is
            when idle =>
                green_light <= '0';
                red_light   <= '0';
            when waitting =>
                green_light <= '0';
                red_light   <= '0';
            when correct_password =>
                green_light <= '1';
                red_light   <= '0';
            when wrong_password =>
                green_light <= '0';
                red_light   <= '1';
            when stop =>
                green_light <= '0';
                red_light   <= '0';
            when others =>
                green_light <= '0';
                red_light   <= '0';
        end case;
    end process;

end architecture logic;
