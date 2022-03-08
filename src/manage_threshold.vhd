----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    02/03/2016 
-- Design Name:    manage_threshold
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

entity manage_threshold is
		port(
		
		--	global
				
		clk			: 	in	STD_LOGIC;
		reset		: 	in	STD_LOGIC;		
		
		--	input
		
		prog_empty	: 	in	STD_LOGIC;
		prog_full	: 	in	STD_LOGIC;
		
		--	output
			
		before_prog_full	: 	out	STD_LOGIC;
		before_prog_empty	: 	out	STD_LOGIC		
		
		);
end entity;

architecture RTL of manage_threshold is

signal out_detect_rising_prog_full	: STD_LOGIC;
signal out_detect_rising_1_prog_full: STD_LOGIC;
signal out_detect_rising_2_prog_full: STD_LOGIC;
signal out_detect_rising_pulse		: STD_LOGIC;

begin
 
-- ----------------------------------------------------
-- manage threshold fifo
-- ----------------------------------------------------

process (clk, reset) begin
if reset = '1' then
before_prog_full <= '0';
before_prog_empty <= '0';
else
	if rising_edge (clk) then
	

		 
		if out_detect_rising_pulse = '1' then
		before_prog_empty <= '0';
		else
			if prog_empty = '1' then
			before_prog_empty <= '1';
			end if;
		end if;	


		if 	out_detect_rising_pulse = '1' then
		before_prog_full <= '1';
		else
			if prog_empty = '1' then
			before_prog_full <= '0';
			end if;
		end if;
	
	end if;
end if;
end process;	

-- ----------------------------------------------------
-- process detect rising edge
-- ----------------------------------------------------
	
	
--	process detect rising edge

label_out_detect_rising_prog_full : process (clk, reset) begin
if reset = '1' then
out_detect_rising_prog_full	<= '0';
else
	if rising_edge (clk) then
	out_detect_rising_prog_full	<= prog_full;
	out_detect_rising_1_prog_full	<= out_detect_rising_prog_full;
	out_detect_rising_2_prog_full	<= out_detect_rising_1_prog_full;
	end if;
end if;
end process;

out_detect_rising_pulse <= out_detect_rising_1_prog_full and (not out_detect_rising_2_prog_full); 


end RTL;