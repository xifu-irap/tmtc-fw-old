----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    01/03/2016 
-- Design Name:    ddr_stamp
-- Module Name:    Ram test - RTL 
-- Project Name:	 ATHENA XIFU
-- Target Devices: xc7k160t
-- Tool versions:  ISE 14.7
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
---------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--	use work.okLibrary.all;
--	use work.FRONTPANEL.all;


library UNISIM;
use UNISIM.VComponents.all;

use work.Ramtest_pack.all;

entity ddr_stamp is
		port(
		
		--	global
				
		clk			: 	in	STD_LOGIC;
		reset		: 	in	STD_LOGIC;		
				
		--	input	
		
		buffer_new_cmd_byte_addr_wr		:	in	STD_LOGIC_VECTOR(54 downto 0);
		buffer_new_cmd_byte_addr_rd		:	in	STD_LOGIC_VECTOR(54 downto 0);
		
		--	output

		Subtraction_addr_wr_addr_rd	:	out	STD_LOGIC_VECTOR(54 downto 0)
		
       			
		);
end entity;

architecture RTL of ddr_stamp is

--signal Subtraction_addr_wr_addr_rd_signal : STD_LOGIC_VECTOR(54 downto 0);

begin
 
-- ----------------------------------------------------
-- 
-- ----------------------------------------------------

process (clk, reset) begin
if reset = '1' then
--Subtraction_addr_wr_addr_rd_signal <= (others => '0');
Subtraction_addr_wr_addr_rd				<= (others => '0');
else
	if rising_edge (clk) then
	--Subtraction_addr_wr_addr_rd_signal	<=	old_cmd_byte_addr_wr - old_cmd_byte_addr_rd;
	Subtraction_addr_wr_addr_rd			<=	buffer_new_cmd_byte_addr_wr - buffer_new_cmd_byte_addr_rd;	 
	end if;
end if;
end process;	


end RTL;