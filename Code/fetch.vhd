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
           i_SR_T_Bit : in STD_LOGIC;
           i_ExpectedTBitValue : in STD_lOGIC;
           i_ControlHazard : in STD_LOGIC;
           i_NewPC : in t_memory_address;
           o_Instruction : out  t_instruction;
           o_CurrentPC : out  t_memory_address);
end FETCH;

architecture a1 of fetch is
    signal r_pc : t_memory_address := (others => '0');
    signal r_ROM : t_memory (0 to 30) := (x"34", x"40", -- mov #68, r0
                                          x"2A", x"00", -- mul r0, r0
                                          x"2A", x"00", -- mul r0, r0
                                          x"30", x"12", -- mov #1, r2
                                          x"30", x"01", -- mov #0, r1
                                          x"23", x"01", -- cmpeq r0, r1
                                          x"14", x"81", -- bf -1
                                          x"28", x"21", -- add r2, r1
                                          x"13", x"84", -- bt -4
                                          x"28", x"2D", -- add r2, r13
                                          others => x"00"); -- nops
begin
    process (i_Clock)
    begin
        if rising_edge(i_Clock) then
            if i_ControlHazard = '1' and i_SR_T_Bit = i_ExpectedTBitValue then
                r_PC <= std_logic_vector(to_unsigned(to_integer(unsigned(i_NewPC)) + 
                                     2, 
                                     i_NewPC'length));
                o_CurrentPC <= i_NewPC;
                o_Instruction <= read16bit(r_ROM, i_NewPC);
            else
                r_PC <= std_logic_vector(to_unsigned(to_integer(unsigned(r_PC)) + 
                                         2, 
                                         r_PC'length));
                o_CurrentPC <= r_pc;
                o_Instruction <= read16bit(r_ROM, r_pc);
            end if;
        end if;
    end process;

end a1;

