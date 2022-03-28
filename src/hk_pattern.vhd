----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    23/06/2016 
-- Design Name:    usb_to_fmc
-- Module Name:    hk_pattern - RTL 
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

-- library UNISIM;
-- use UNISIM.VComponents.all;

--use work.remote_ctrl_ddr3.all;

entity hk_pattern is
		port(
			
		okClk		: 	in	STD_LOGIC;
		reset		: 	in	STD_LOGIC;
		
		rd_data_count_hk	:	in	std_logic_vector(9 downto 0);

		ep26wire			: 	out	std_logic_vector(31 downto 0)
		
		);
end entity;

architecture RTL of hk_pattern is

begin



fsm_hk	:	process(reset, okClk)
begin
if reset = '1'
then 
	
ep26wire		<= x"00000000";

else
	if okClk = '1' and okClk' event
	then 
	
--	truncation LSB pour obtenir un multiple de 4 mots de 32 bits, donc des multiples de 16 octets, 
--	le tout remultiplier par 4 pour obtenir le bon nombre de mot de 32 bit a lire (le gse remultiplie par 4 pour obtenir le nombre d'octet a lire). 
 
	ep26wire		<= x"0000"&(rd_data_count_hk(9 downto 2) * x"04");
	
	end if;
end if;
end process;


	
		
end RTL;