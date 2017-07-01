----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:24:11 06/26/2017 
-- Design Name: 
-- Module Name:    decode - Behavioral 
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

entity decode is
    Port ( i_Clock : in  STD_LOGIC;
          -- i_CurrentPC : in t_memory_address;
           i_Instruction : in  t_instruction;
           --o_ControlHazard : out  STD_LOGIC;
           --o_NewPC : in  t_memory_address;
           o_alu_cmd : out t_alu_command;
           o_ReadCmd : out t_registers_read_command);
end decode;

architecture a1 of decode is 
    constant c_REMEMBER_CYCLES_COUNT : integer := 2;
    type t_cycles_register_usage is array(0 to c_REMEMBER_CYCLES_COUNT - 1) of t_alu_output_parameter;
    
    function fix_bus_for_data_hazards(i_parameter : t_alu_parameter;
                                      i_cycles_register_usage : t_cycles_register_usage;
                                      i_ReadCmd : t_registers_read_command)
             return integer is
             variable v_bus_select : t_bus_id := 0;
    begin
        v_bus_select := i_parameter.bus_select;
        for index in 0 to i_cycles_register_usage'length - 1 loop
            -- if bus 0 and register select same as cycle then use cycle bus instead
            if i_parameter.bus_select = 0 and 
            i_ReadCmd.register_a = i_cycles_register_usage(index).register_select and
            i_cycles_register_usage(index).ptype = ALU_OUTPUT_PARAMETER_REGISTER then
                v_bus_select := index + 2;
            else
                -- if bus 1 and register select same as cycle then use cycle bus instead
                if i_parameter.bus_select = 1 and 
                i_ReadCmd.register_b = i_cycles_register_usage(index).register_select and
                i_cycles_register_usage(index).ptype = ALU_OUTPUT_PARAMETER_REGISTER then
                    v_bus_select := index + 2;
                end if;
            end if;
        end loop;
        return v_bus_select;
    end function fix_bus_for_data_hazards;
begin

    process (i_Clock)
        variable v_opcode_group : std_logic_vector(0 to 3) := (others => '0');
        variable v_opcode_id : std_logic_vector(0 to 3) := (others => '0');
        variable v_alu_cmd : t_alu_command := (operation => ALU_NONE,
                                             parameter1 => (ptype => ALU_PARAMETER_NONE,
                                                            bus_select => 0,
                                                            imm_select => (others => '0')),
                                             parameter2 => (ptype => ALU_PARAMETER_NONE,
                                                            bus_select => 1,
                                                            imm_select => (others => '0')),
                                             output => (ptype => ALU_OUTPUT_PARAMETER_NONE,
                                                        register_select => (others => '0')));
        variable v_registers_read_cmd : t_registers_read_command := (register_a => (others => '0'),
                                                                 register_b => (others => '0'));
        variable r_cycles_register_usage : t_cycles_register_usage := (others => (
                                                                    ptype => ALU_OUTPUT_PARAMETER_NONE,
                                                                    register_select => (others => '0')
                                                                 ));
    begin
        if rising_edge(i_Clock) then
            v_opcode_group := i_Instruction(0 to 3);
            v_opcode_id := i_Instruction(4 to 7);
            v_alu_cmd.parameter1.ptype := ALU_PARAMETER_BUS;
            v_alu_cmd.parameter1.bus_select := 0;
            v_alu_cmd.parameter2.ptype := ALU_PARAMETER_BUS;
            v_alu_cmd.parameter2.bus_select := 1;
            v_alu_cmd.output.ptype := ALU_OUTPUT_PARAMETER_REGISTER;
            v_alu_cmd.output.register_select := i_Instruction(12 to 15);
                        
            case v_opcode_group is
                when "0000" =>
                    -- NOP
                    v_alu_cmd.operation := ALU_NONE;
                    v_alu_cmd.output.ptype := ALU_OUTPUT_PARAMETER_NONE;
                when "0001" =>
                    -- SHL, SHR, BE, BG, BL, JMP, PUSH, POP               
                when "0010" =>
                    -- CMP, NOT, AND, OR, XOR, ADD, SUB, MUL, DIV,
                    -- MOV (Rn -> Rm, [Rn] -> Rm, Rn -> [Rm])
                    v_registers_read_cmd.register_a := i_Instruction(8 to 11);
                    v_registers_read_cmd.register_b := i_Instruction(12 to 15);
                    case v_opcode_id is
                        when "0000" => -- MOV   Rn, Rm
                            v_alu_cmd.operation := ALU_ADD;
                            v_alu_cmd.parameter1.ptype := ALU_PARAMETER_IMMEDIATE;
                            v_alu_cmd.parameter1.imm_select := x"00";
                            v_registers_read_cmd.register_b := (others => '0'); -- uses only 1 register
                        when "0001" => -- MOV   [Rn], Rm
                        when "0010" => -- MOV   Rn, [Rm]
                        when "0011" => -- CMP	Rn, Rm
                            v_alu_cmd.operation := ALU_CMP;
                            v_alu_cmd.output.register_select := REGISTER_SR;
                        when "0100" => -- NOT	Rn, Rm
                            v_alu_cmd.operation := ALU_NOT;
                            v_alu_cmd.parameter1.ptype := ALU_PARAMETER_NONE;
                            v_registers_read_cmd.register_b := (others => '0'); -- uses only 1 register
                        when "0101" => -- AND	Rn, Rm
                            v_alu_cmd.operation := ALU_AND;
                        when "0110" => -- OR	Rn, Rm
                            v_alu_cmd.operation := ALU_OR;
                        when "0111" => -- XOR	Rn, Rm
                            v_alu_cmd.operation := ALU_XOR;
                        when "1000" => -- ADD	Rn, Rm
                            v_alu_cmd.operation := ALU_ADD;
                        when "1001" => -- SUB	Rn, Rm
                            v_alu_cmd.operation := ALU_SUB;
                        when "1010" => -- MUL	Rn, Rm
                            v_alu_cmd.operation := ALU_MUL;
                        when "1011" => -- DIV	Rn, Rm
                            v_alu_cmd.operation := ALU_DIV;
                        when others =>
                            -- illegal instruction
                            v_alu_cmd.operation := ALU_NONE;
                            v_alu_cmd.output.ptype := ALU_OUTPUT_PARAMETER_NONE;
                            v_alu_cmd.output.register_select := (others => '0');
                    end case;
                when "0011" =>
                    -- MOV (immediate -> Rn)
                    v_alu_cmd.operation := ALU_ADD;
                    v_alu_cmd.parameter1.ptype := ALU_PARAMETER_IMMEDIATE;
                    v_alu_cmd.parameter1.imm_select := i_Instruction(4 to 11);
                    v_alu_cmd.parameter2.ptype := ALU_PARAMETER_IMMEDIATE;
                    v_alu_cmd.parameter2.imm_select := x"00";
                when others =>
                    -- illegal instruction
                    v_alu_cmd.operation := ALU_NONE;
                    v_alu_cmd.output.ptype := ALU_OUTPUT_PARAMETER_NONE;
                    v_alu_cmd.output.register_select := (others => '0');
            end case;
            
            -- Checking if registers were used in previous saved cycles and updates bus selection in order to deal with data hazards
            if v_alu_cmd.parameter1.ptype = ALU_PARAMETER_BUS then
                v_alu_cmd.parameter1.bus_select := fix_bus_for_data_hazards(v_alu_cmd.parameter1,
                                                                            r_cycles_register_usage,
                                                                            v_registers_read_cmd);
            end if;
            if v_alu_cmd.parameter2.ptype = ALU_PARAMETER_BUS then
                v_alu_cmd.parameter2.bus_select := fix_bus_for_data_hazards(v_alu_cmd.parameter2,
                                                                            r_cycles_register_usage,
                                                                            v_registers_read_cmd);
            end if;
            
            -- shifting data to save the new cycle
            for index in 1 to r_cycles_register_usage'length - 1 loop
                r_cycles_register_usage(index) := r_cycles_register_usage(index - 1);
            end loop;
            r_cycles_register_usage(0) := v_alu_cmd.output;
            
            o_alu_cmd <= v_alu_cmd;
            o_ReadCmd <= v_registers_read_cmd;
        end if;
    end process;

end a1;

