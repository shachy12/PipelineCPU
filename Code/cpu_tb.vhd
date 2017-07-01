--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:26:34 06/26/2017
-- Design Name:   
-- Module Name:   C:/Users/DELL/Desktop/Projects/FPGA/PipelineCPU/Code/cpu_tb.vhd
-- Project Name:  Code
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fetch
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.cpu_pack.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cpu_tb IS
END cpu_tb;
 
ARCHITECTURE behavior OF cpu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fetch
    PORT(
         i_Clock : IN  std_logic;
         i_ControlHazard : IN  std_logic;
         i_NewPC : IN  std_logic_vector(0 to 31);
         o_Instruction : OUT  std_logic_vector(0 to 15);
         o_CurrentPC : OUT  std_logic_vector(0 to 31)
        );
    END COMPONENT;
    

   --Inputs
   signal i_Clock : std_logic := '0';
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
   signal o_registers_read_bus : t_bus_2d := ((others => '0'),
                                              (others => '0'));
   
   COMPONENT decode
    Port ( i_Clock : in  STD_LOGIC;
          -- i_CurrentPC : in t_memory_address;
           i_Instruction : in  t_instruction;
           --o_ControlHazard : out  STD_LOGIC;
           --o_NewPC : in  t_memory_address;
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
                                                   
   COMPONENT alu
    Port ( i_Clock : in  STD_LOGIC;
           i_Command: in t_alu_command;
           i_bus : in t_bus_4d;
           o_RamCmd : out t_ram_command);
    END COMPONENT;
    
    -- Inputs
    signal i_bus : t_bus_4d := (others => (others => '0'));
    
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
   -- Clock period definitions
   constant i_Clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   FetchStage: fetch PORT MAP (
          i_Clock => i_Clock,
          i_ControlHazard => i_ControlHazard,
          i_NewPC => i_NewPC,
          o_Instruction => o_Instruction,
          o_CurrentPC => o_CurrentPC
        );
        
   DecodeStage : decode PORT MAP (
          i_Clock => i_Clock,
          i_Instruction => o_Instruction,
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
          o_RamCmd => i_RamCmd
        );
   
   RamStage : RAM GENERIC MAP(RAM_SIZE => 10 * 1024) -- 10 KB
                  PORT MAP(i_Clock => i_Clock,
                           i_RamCmd => i_RamCmd,
                           o_WriteCmd => i_WriteCmd
               );
        
   RegistersFile : registers_file PORT MAP (
          i_Clock => i_Clock,
          i_ReadCmd => i_ReadCmd,
          i_WriteCmd => i_WriteCmd,
          o_registers_read_bus => o_registers_read_bus
        );
   
   -- Clock process definitions
   i_Clock_process :process
   begin
		i_Clock <= '0';
		wait for i_Clock_period/2;
		i_Clock <= '1';
		wait for i_Clock_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
--      wait for 100 ns;	
--
--      wait for i_Clock_period*10;

      -- insert stimulus here 
      wait for i_Clock_period;
      if o_Instruction = x"3080" then
        report "Test 1 Passed" severity note;
      else
        report "Test 1 Failed" severity failure;
      end if;
      wait for i_Clock_period;
      
--      if o_Instruction = x"0000" then
--        report "Test 2 Passed" severity note;
--      else
--        report "Test 2 Failed" severity failure;
--      end if;
--      wait for i_Clock_period;
--      
--      if o_Instruction = x"0000" then
--        report "Test 3 Passed" severity note;
--      else
--        report "Test 3 Failed" severity failure;
--      end if;
--      wait for i_Clock_period;
      
      if o_Instruction = x"2001" then
        report "Test 4 Passed" severity note;
      else
        report "Test 4 Failed" severity failure;
      end if;
      wait;
   end process;

END;
