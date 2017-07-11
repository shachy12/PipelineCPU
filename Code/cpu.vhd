----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:27:41 07/04/2017 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

entity cpu is
    Port ( i_Clock : in  STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR(0 to 7));
end cpu;

architecture Behavioral of cpu is
     COMPONENT fetch
    PORT(
         i_Clock : IN  std_logic;
         i_SR_T_Bit : IN std_logic;
         i_ExpectedTBitValue : in STD_lOGIC;
         i_ControlHazard : IN  std_logic;
         i_NewPC : IN  std_logic_vector(0 to 31);
         o_Instruction : OUT  std_logic_vector(0 to 15);
         o_CurrentPC : OUT  std_logic_vector(0 to 31)
        );
    END COMPONENT;
    

   --Inputs
   signal i_ControlHazard : std_logic := '0';
   signal i_NewPC : std_logic_vector(0 to 31) := (others => '0');

 	--Outputs
   signal o_Instruction : std_logic_vector(0 to 15) := (others => '0'); -- Initialize to NOP
   signal o_CurrentPC : std_logic_vector(0 to 31) := (others => '0');

   COMPONENT registers_file
   PORT(
         i_Clock : IN  std_logic;
         i_ReadCmd : in t_registers_read_command;
         i_WriteCmd : in t_registers_write_command;
         o_gpio : out STD_LOGIC_VECTOR(0 to 7);
         o_registers_read_bus : out t_bus_2d
        );
   END COMPONENT;
    

   --Inputs
   signal i_ReadCmd : t_registers_read_command := (register_a => (others => '0'),
                                                   register_b => (others => '0'));
   signal i_WriteCmd : t_registers_write_command := (write_enable => '0',
                                                     register_select => (others => '0'),
                                                     write_value => (others => '0'));

 	--Outputs
   signal o_gpio : STD_LOGIC_VECTOR(0 to 7) := (others => '0');
   signal o_registers_read_bus : t_bus_2d := ((others => '0'),
                                              (others => '0'));
   
   COMPONENT decode
    Port ( i_Clock : in  STD_LOGIC;
           i_CurrentPC : in t_memory_address;
           i_Instruction : in  t_instruction;
           o_ControlHazard : out  STD_LOGIC;
           o_NewPC : out  t_memory_address;
           o_ExpectedTBitValue : out STD_LOGIC;
           o_alu_cmd : out t_alu_command;
           o_ReadCmd : out t_registers_read_command);
    END COMPONENT;
    
    --Outputs
   signal o_alu_cmd : t_alu_command := (operation => ALU_NONE,
                                        parameter1 => (ptype => ALU_PARAMETER_NONE,
                                                       bus_select => 0,
                                                       imm_select => (others => '0')),
                                        parameter2 => (ptype => ALU_PARAMETER_NONE,
                                                       bus_select => 1,
                                                       imm_select => (others => '0')),
                                        output => (ptype => ALU_OUTPUT_PARAMETER_NONE,
                                                   register_select => (others => '0')));
   signal o_ExpectedTBitValue : std_logic := '0';
                                                   
   COMPONENT alu
    Port ( i_Clock : in  STD_LOGIC;
           i_Command: in t_alu_command;
           i_bus : in t_bus_4d;
           o_RamCmd : out t_ram_command;
           i_CurrentPC : t_memory_address;
           o_SR_T_Bit : out STD_LOGIC);
    END COMPONENT;
    
    -- Inputs
    signal i_bus : t_bus_4d := (others => (others => '0'));
    
    -- Outputs
    signal o_SR_T_Bit : STD_LOGIC := '0';
    
    COMPONENT RAM
     generic (
        RAM_SIZE : positive
     );
     Port ( i_Clock : in  STD_LOGIC;
            i_RamCmd : in  t_ram_command;
            o_WriteCmd : out t_registers_write_command);
    END COMPONENT;

    -- Inputs
    signal i_RamCmd : t_ram_command := (cmd_type => RAM_NONE,
                                        address => (others => '0'),
                                        register_select => (others => '0'),
                                        write_value => (others => '0'),
                                        size => 0);
begin

    FetchStage: fetch PORT MAP (
          i_Clock => i_Clock,
          i_SR_T_Bit => o_SR_T_Bit,
          i_ExpectedTBitValue => o_ExpectedTBitValue,
          i_ControlHazard => i_ControlHazard,
          i_NewPC => i_NewPC,
          o_Instruction => o_Instruction,
          o_CurrentPC => o_CurrentPC
        );
        
   DecodeStage : decode PORT MAP (
          i_Clock => i_Clock,
          i_CurrentPC => o_CurrentPC,
          i_Instruction => o_Instruction,
          o_ControlHazard => i_ControlHazard,
          o_NewPC => i_NewPC,
          o_ExpectedTBitValue => o_ExpectedTBitValue,
          o_alu_cmd => o_alu_cmd,
          o_ReadCmd => i_ReadCmd
        );
   
   -- Bus for ALU, the alu implements a multiplexer that select data from the bus
   i_bus(0) <= o_registers_read_bus(0);
   i_bus(1) <= o_registers_read_bus(1);
   i_bus(2) <= i_RamCmd.write_value;
   i_bus(3) <= i_WriteCmd.write_value;
   
   AluStage : alu PORT MAP (
          i_Clock => i_Clock,
          i_Command => o_alu_cmd,
          i_bus => i_bus,
          o_RamCmd => i_RamCmd,
          i_CurrentPC => o_CurrentPC,
          o_SR_T_Bit => o_SR_T_Bit
        );
   
   RamStage : RAM GENERIC MAP(RAM_SIZE => 10) -- 10 bytes
                  PORT MAP(i_Clock => i_Clock,
                           i_RamCmd => i_RamCmd,
                           o_WriteCmd => i_WriteCmd
               );
        
   RegistersFile : registers_file PORT MAP (
          i_Clock => i_Clock,
          i_ReadCmd => i_ReadCmd,
          i_WriteCmd => i_WriteCmd,
          o_gpio => o_gpio,
          o_registers_read_bus => o_registers_read_bus
        );
    LED <= o_gpio;
end Behavioral;

