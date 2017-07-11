----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:07:45 06/26/2017 
-- Design Name: 
-- Module Name:    registers_file - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use work.cpu_pack.all;
use IEEE.NUMERIC_STD.ALL;

entity registers_file is
    Port ( i_Clock : in  STD_LOGIC;
           i_ReadCmd : t_registers_read_command;
           i_WriteCmd : in t_registers_write_command;
           o_gpio : out STD_LOGIC_VECTOR(0 to 7);
           o_registers_read_bus : out t_bus_2d);
end registers_file;

architecture a1 of registers_file is
    signal r_registers : t_registers := (others => x"00000000");
begin

    process (i_Clock, i_WriteCmd, i_ReadCmd, r_registers)
    begin
        if rising_edge(i_Clock) and i_WriteCmd.write_enable = '1' then
            r_registers(to_integer(unsigned(i_WriteCmd.register_select))) <= i_WriteCmd.write_value;
        end if;
        
        o_registers_read_bus <= (r_registers(to_integer(unsigned(i_ReadCmd.register_a))),
                                 r_registers(to_integer(unsigned(i_ReadCmd.register_b))));
        o_gpio <= r_registers(13)(24 to 31);
    end process;

end a1;

