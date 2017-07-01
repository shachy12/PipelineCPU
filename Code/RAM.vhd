----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:32:34 06/20/2017 
-- Design Name: 
-- Module Name:    RAM - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use work.cpu_pack.all;


entity RAM is
    generic (
        RAM_SIZE : positive
    );
    Port ( i_Clock : in  STD_LOGIC;
           i_RamCmd : in  t_ram_command;
           o_WriteCmd : out t_registers_write_command);
end RAM;

architecture a1 of RAM is
    signal r_RAM : t_memory (0 to RAM_SIZE) := (others => x"00");
begin

process (i_Clock)
begin
    if rising_edge(i_Clock) then
        case i_RamCmd.cmd_type is
            when RAM_WRITE =>
                o_WriteCmd.write_enable <= '0';
                o_WriteCmd.register_select <= (others => '0');
                o_WriteCmd.write_value <= (others => '0');
                if i_RamCmd.size >= 1 then
                    write8bit(r_RAM, i_RamCmd.address, i_RamCmd.write_value(24 to 31));
                end if;
                if i_RamCmd.size >= 2 then
                    write8bit(r_RAM, i_RamCmd.address, i_RamCmd.write_value(16 to 23));
                end if;
                if i_RamCmd.size >= 3 then
                    write8bit(r_RAM, i_RamCmd.address, i_RamCmd.write_value(8 to 15));
                end if;
                if i_RamCmd.size = 4 then
                    write8bit(r_RAM, i_RamCmd.address, i_RamCmd.write_value(0 to 7));
                end if;
            when RAM_READ =>
                o_WriteCmd.write_enable <= '1';
                o_WriteCmd.register_select <= i_RamCmd.register_select;
                case i_RamCmd.size is
                    when 1 =>
                        o_WriteCmd.write_value(24 to 31) <= read8bit(r_RAM, i_RamCmd.address);
                    when 2 =>
                        o_WriteCmd.write_value(16 to 31) <= read16bit(r_RAM, i_RamCmd.address);
                    when 4 =>
                        o_WriteCmd.write_value <= read32bit(r_RAM, i_RamCmd.address);
                    when others =>
                        -- TODO: handle error
                end case;
            when RAM_PASS_WRITEBACK =>
                o_WriteCmd.write_enable <= '1';
                o_WriteCmd.register_select <= i_RamCmd.register_select;
                o_WriteCmd.write_value <= i_RamCmd.write_value;
            when others =>
                o_WriteCmd.write_enable <= '0';
                o_WriteCmd.register_select <= (others => '0');
                o_WriteCmd.write_value <= (others => '0');
        end case;
    end if;
end process;

end a1;

