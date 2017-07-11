--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package cpu_pack is
    constant c_instruction_size : integer := 16; -- 16 bit size
    subtype t_memory_address is std_Logic_vector(0 to 31);
    subtype t_instruction is std_Logic_vector(0 to (c_instruction_size - 1));
    type t_memory is array (NATURAL range <>) of std_Logic_vector(0 to 7);
    subtype t_register is std_Logic_vector(0 to 31);
    type t_registers is array (0 to 15) of t_register;
    subtype t_register_id is std_logic_vector(0 to 3);
    subtype t_bus_id is integer range 0 to 3;

    function read8bit(i_Memory : t_memory;
                      i_MemoryAddress : t_memory_address)
             return std_logic_vector;
    function read16bit(i_Memory : t_memory;
                      i_MemoryAddress : t_memory_address)
             return std_logic_vector;
    function read32bit(i_Memory : t_memory;
                      i_MemoryAddress : t_memory_address)
             return std_logic_vector;
             
    function get_value_in_register(i_Registers : t_registers;
                                   i_RegisterIndex : t_register_id)
             return std_logic_vector;
             
    constant REGISTER_SR : t_register_id := "1110";
    constant REGISTER_SR_T_BIT : integer := 0;
    
    type t_alu_operation is (ALU_NONE,
                             ALU_NOT,
                             ALU_AND,
                             ALU_OR,
                             ALU_XOR,
                             ALU_ADD,
                             ALU_SUB,
                             ALU_MUL,
                             ALU_DIV,
                             ALU_CMPEQ,
                             ALU_CMPG,
                             ALU_CMPL
                             );
    type t_alu_parameter_type is (ALU_PARAMETER_NONE,
                                  ALU_PARAMETER_IMMEDIATE,
                                  ALU_PARAMETER_BUS,
                                  ALU_PARAMETER_TEMP);
                                  
    type t_alu_parameter is record
        ptype : t_alu_parameter_type;
        bus_select : t_bus_id;
        imm_select : std_logic_vector(0 to 7);
    end record;
    
    type t_alu_output_parameter_type is (ALU_OUTPUT_PARAMETER_NONE,
                                         ALU_OUTPUT_PARAMETER_REGISTER,
                                         ALU_OUTPUT_PARAMETER_DECODE_BUS,
                                         ALU_OUTPUT_PARAMETER_TEMP);
    
    type t_alu_output_parameter is record
        ptype : t_alu_output_parameter_type;
        register_select : t_register_id;
    end record;
    
    type t_alu_command is record
        operation : t_alu_operation;
        parameter1 : t_alu_parameter;
        parameter2 : t_alu_parameter;
        output : t_alu_output_parameter;
    end record;
    
    type t_registers_write_command is record
        write_enable : std_logic;
        register_select : t_register_id;
        write_value : t_register;
    end record;
    
    type t_registers_read_command is record
        register_a : t_register_id;
        register_b : t_register_id;
    end record;
    
    type t_opcode_data is record
        instruction : t_instruction;
        pc : t_memory_address;
    end record;
    
    type t_fetch_opcodes_bus is array(0 to 1) of t_opcode_data;
    
    type t_bus_2d is array (0 to 1) of t_register;
    type t_bus_4d is array (0 to 3) of t_register;
    constant BUS_A : integer := 0;
    constant BUS_B : integer := 1;
    
    type t_ram_cmd_type is (RAM_NONE, RAM_PASS_WRITEBACK, RAM_READ, RAM_WRITE);
    type t_ram_command is record
        cmd_type : t_ram_cmd_type;
        address : t_memory_address;
        register_select : t_register_id;
        write_value : t_register;
        size : integer range 0 to 4;
    end record;
    procedure write8bit(signal o_Memory : out t_memory;
                        signal i_MemoryAddress : in t_memory_address;
                        signal i_WriteValue : in std_logic_vector(0 to 7));
end cpu_pack;

package body cpu_pack is
    function get_value_in_register(i_Registers : t_registers;
                                   i_RegisterIndex : t_register_id)
             return std_logic_vector is
             variable v_register_data : t_register;
    begin
        v_register_data := i_Registers(to_integer(unsigned(i_RegisterIndex)));
        return v_register_data;
    end function get_value_in_register;
                                   
    function read8bit(i_Memory : t_memory;
                      i_MemoryAddress : t_memory_address)
             return std_logic_vector is
             variable v_data : std_logic_vector(0 to 7) := (others => '0');
    begin
        if to_integer(unsigned(i_MemoryAddress)) < i_Memory'length then
            v_data := i_Memory(to_integer(unsigned(i_MemoryAddress)));
        end if;
        return v_data;
    end function read8bit;
    
    function read16bit(i_Memory : t_memory;
                       i_MemoryAddress : t_memory_address)
             return std_logic_vector is
             variable v_data : std_logic_vector(0 to 15) := (others => '0');
    begin
        v_data(0 to 7) := read8bit(i_Memory,
                                   i_MemoryAddress);
        v_data(8 to 15) := read8bit(i_Memory,
                                    std_logic_vector(to_unsigned(
                                    to_integer(unsigned(i_MemoryAddress)) + 1,
                                    i_MemoryAddress'length)));
        return v_data;
    end function read16bit;
    
    function read32bit(i_Memory : t_memory;
                      i_MemoryAddress : t_memory_address)
             return std_logic_vector is
             variable v_data : std_logic_vector(0 to 31) := (others => '0');
    begin
        v_data(0 to 15) := read16bit(i_Memory,
                                     i_MemoryAddress);
        v_data(16 to 31) := read16bit(i_Memory,
                                      std_logic_vector(to_unsigned(
                                      to_integer(unsigned(i_MemoryAddress)) + 2,
                                      i_MemoryAddress'length)));
        return v_data;
    end function read32bit;
    
    procedure write8bit(signal o_Memory : out t_memory;
                        signal i_MemoryAddress : in t_memory_address;
                        signal i_WriteValue : in std_logic_vector(0 to 7)) is
    begin
        if to_integer(unsigned(i_MemoryAddress)) < o_Memory'length then
            o_Memory(to_integer(unsigned(i_MemoryAddress))) <= i_WriteValue;
        end if;
    end procedure write8bit;
end cpu_pack;
