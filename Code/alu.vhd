----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:44:55 06/26/2017 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

entity alu is
    Port ( i_Clock : in  STD_LOGIC;
           i_Command: in t_alu_command;
           i_bus : in t_bus_4d;
           o_RamCmd : out t_ram_command;
           i_CurrentPC : t_memory_address;
           o_SR_T_Bit : out STD_LOGIC);
end alu;

architecture a1 of alu is    
    function load_parameter(i_parameter : t_alu_parameter;
                            i_bus : t_bus_4d)
             return unsigned is
             variable v_data : unsigned(0 to 31) := (others => '0');
    begin
        case i_parameter.ptype is
            when ALU_PARAMETER_BUS =>
                v_data := unsigned(i_bus(i_parameter.bus_select));
            when ALU_PARAMETER_IMMEDIATE =>
                v_data := (others => '0');
                v_data(24 to 31) := unsigned(i_parameter.imm_select);
            when others =>
                -- do nothing
                v_data := (others => '0');
        end case;
        return v_data;
    end function load_parameter;
    signal r_SR_T_Bit : std_logic := '0';
begin
    process (i_Clock)
        variable v_value1 : unsigned(0 to 31) := (others => '0');
        variable v_value2 : unsigned(0 to 31) := (others => '0');
        variable v_output : unsigned(0 to 31) := (others => '0');
        variable v_mul_output : unsigned(0 to 63) := (others => '0');
        variable v_SR_T_Bit : std_Logic := '0';
    begin
        if rising_edge(i_Clock) then
            
            v_value1 := load_parameter(i_Command.parameter1,
                                      i_bus);
            v_value2 := load_parameter(i_Command.parameter2,
                                      i_bus);
            case i_Command.operation is
                when ALU_NONE =>
                when ALU_NOT =>
                    v_output := not v_value1;
                when ALU_AND =>
                    v_output := v_value1 and v_value2;
                when ALU_OR =>
                    v_output := v_value1 or v_value2;
                when ALU_XOR =>
                    v_output := v_value1 xor v_value2;
                when ALU_ADD =>
                    v_output := v_value1 + v_value2;
                when ALU_SUB =>
                    v_output := v_value1 - v_value2;
                when ALU_MUL =>
                    v_mul_output := (v_value1 * v_value2);
                    v_output := v_mul_output(32 to 63);
                when ALU_DIV =>
                    v_output := v_value1 / v_value2;
                when ALU_CMPEQ =>
                    v_output := (others => '0');
                    
                    if v_value1 = v_value2 then
                        v_output(REGISTER_SR_T_BIT) := '1';
                        v_SR_T_Bit := '1';
                    else
                        v_output(REGISTER_SR_T_BIT) := '0';
                        v_SR_T_Bit := '0';
                    end if;
                when ALU_CMPG =>
                    v_output := (others => '0');
                    
                    if v_value1 > v_value2 then
                        v_output(REGISTER_SR_T_BIT) := '1';
                        o_SR_T_Bit <= '1';
                    else
                        v_output(REGISTER_SR_T_BIT) := '0';
                        o_SR_T_Bit <= '0';
                    end if;
                when ALU_CMPL =>
                    v_output := (others => '0');
                    
                    if v_value1 < v_value2 then
                        v_output(REGISTER_SR_T_BIT) := '1';
                        o_SR_T_Bit <= '1';
                    else
                        v_output(REGISTER_SR_T_BIT) := '0';
                        o_SR_T_Bit <= '0';
                    end if;
                when others =>
                    -- Unknown Operation
            end case;
            if i_Command.output.ptype = ALU_OUTPUT_PARAMETER_REGISTER then
                o_RamCmd.cmd_type <= RAM_PASS_WRITEBACK;
                o_RamCmd.register_select <= i_Command.output.register_select;
                o_RamCmd.write_value <= t_register(v_output);
                o_RamCmd.size <= 0;
                o_RamCmd.address <= (others => '0');
            else
                o_RamCmd.cmd_type <= RAM_NONE;
                o_RamCmd.register_select <= (others => '0');
                o_RamCmd.write_value <= (others => '0');
                o_RamCmd.size <= 0;
                o_RamCmd.address <= (others => '0');
            end if;
            o_SR_T_Bit <= v_SR_T_Bit;
        end if;
    end process;

end a1;

