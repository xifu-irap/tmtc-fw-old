----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    09/03/2016 
-- Design Name:    manage_pipe_out
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

--use work.Ramtest_pack.all;

entity manage_pipe_out is
		port(
		
		--	global
				
		clk					: 	in	STD_LOGIC;
		okClk				: 	in	STD_LOGIC;
		reset				: 	in	STD_LOGIC;		
		
		--	fifo interface
		
		rd_data_count		:	in	STD_LOGIC_VECTOR(16 downto 0);
		
		--	ctrl interface
		
		ep20wire_three		: 	out STD_LOGIC_VECTOR(31 downto 0)
 			
		);
end entity;

architecture RTL of manage_pipe_out is


begin





process (okClk, reset) begin
if reset = '1' then

ep20wire_three	<= (others => '0');

else
	if rising_edge (okClk) then
			
	ep20wire_three <= x"0000"&'0'&(rd_data_count(16 downto 2)); 
			
	end if;
end if;
end process;	






end RTL;