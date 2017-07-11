--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:41:42 06/26/2017
-- Design Name:   
-- Module Name:   C:/Users/DELL/Desktop/Projects/FPGA/PipelineCPU/Code/decode_tb.vhd
-- Project Name:  Code
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: registers_file
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY decode_tb IS
END decode_tb;
 
ARCHITECTURE behavior OF decode_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT registers_file
    PORT(
         i_Clock : IN  std_logic;
         i_ReadCmd : IN  std_logic;
         i_WriteCmd : IN  std_logic;
         o_registers_read_bus : OUT  std_logic_vector(0 to 1)
        );
    END COMPONENT;
    

   --Inputs
   signal i_Clock : std_logic := '0';
   signal i_ReadCmd : std_logic := '0';
   signal i_WriteCmd : std_logic := '0';

 	--Outputs
   signal o_registers_read_bus : std_logic_vector(0 to 1);

   -- Clock period definitions
   constant i_Clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: registers_file PORT MAP (
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
      wait for 100 ns;	

      wait for i_Clock_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
