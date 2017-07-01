----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:42:34 06/26/2017 
-- Design Name: 
-- Module Name:    FETCH - a1 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fetch is
    Port ( i_Clock : in  STD_LOGIC;
           i_ControlHazard : in  STD_LOGIC;
           i_NewPC : in  t_memory_address;
           o_Instruction : out  t_instruction;
           o_CurrentPC : out  t_memory_address);
end FETCH;

architecture a1 of fetch is
    signal r_pc : t_memory_address := (others => '0');
    signal r_ROM : t_memory (0 to 5) := (x"30", x"80", -- mov #8, r0
                                         x"20", x"01", -- mov r0, r1
                                         x"23", x"01" -- cmp r0, r1
                                         );
begin
    process (i_Clock)
    begin
        if rising_edge(i_Clock) then
            if i_ControlHazard = '1' then
                r_pc <= i_NewPC;
            else
                r_PC <= std_logic_vector(to_unsigned(to_integer(unsigned(r_PC)) + 
                                         2, 
                                         r_PC'length));
            end if;
            o_CurrentPC <= r_pc;
            o_Instruction <= read16bit(r_ROM, r_pc);
        end if;
    end process;

end a1;

