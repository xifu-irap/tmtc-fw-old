----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    09/03/2016 
-- Design Name:    start_stop
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

entity start_stop is
		port(
		
		--	global
				
		clk					: 	in	STD_LOGIC;
		reset				: 	in	STD_LOGIC;		
				
		--	input	
		
		write_instrument	: 	in	STD_LOGIC;
		ack_time_out		: 	in	STD_LOGIC;
		time_out_type		: 	in	STD_LOGIC;
		
		--	output
	
		time_out			: 	out	STD_LOGIC
		
       			
		);
end entity;

architecture RTL of start_stop is

constant cte_count_time_out	: integer := 200000; -- time out greather than 256, because pipe in packet is 1024 bytes
signal count_time_out		: integer;

signal write_instrument_1	: 	STD_LOGIC;
signal write_instrument_2	: 	STD_LOGIC;
signal write_instrument_1_level	: 	STD_LOGIC;
signal write_instrument_2_level	: 	STD_LOGIC;
signal write_instrument_3		: 	STD_LOGIC;
signal write_instrument_3_level	: 	STD_LOGIC;
signal write_instrument_3_edge	: 	STD_LOGIC; 

signal enable_time_out			: 	STD_LOGIC;

begin
 
process (clk, reset) begin
if reset = '1' then
write_instrument_1_level	<= '0';
write_instrument_2_level	<= '0';	
write_instrument_3_level	<= '0';	
else
	if rising_edge (clk) then
	write_instrument_1_level <= write_instrument;
	write_instrument_2_level <= write_instrument_1_level;
	write_instrument_3_level <= write_instrument_2_level;
	end if;
end if;
end process; 
 
 
write_instrument_3 <= write_instrument_3_edge when time_out_type = '0' else write_instrument_3_level;  
 
----------------------------------------------------
--	time out processing
----------------------------------------------------

process (clk, reset) begin	--	wr_clk
if reset = '1' then
count_time_out		<= 0;
time_out			<= '0';
enable_time_out		<= '0';
else
	if rising_edge (clk) then	--	wr_clk

		-- if enable_time_out = '1'  then
		-- count_time_out <= count_time_out + 1;
		-- else
		-- count_time_out		<= 0;
		-- end if;
		
		-- if ack_time_out = '1' then
		-- enable_time_out <= '0';
		-- else
			-- if write_instrument_2 = '1' then
			-- enable_time_out <= '1';
			-- end if;
		-- end if;	

		if write_instrument_3 = '1'	then	--	each write reset timeout		
		count_time_out		<= 0;
		time_out			<= '0';
		enable_time_out 	<= '1';
		else
			if	ack_time_out = '1'  then	--	fsm manager dumping
			count_time_out		<= 0;
			time_out			<= '0';
			enable_time_out 	<= '0';
			else
				if enable_time_out = '1'  then
				count_time_out <= count_time_out + 1;
					if (count_time_out >= cte_count_time_out) then
					time_out			<= '1';
					count_time_out		<= 0;
					end if;
				else
				count_time_out		<= 0;
				end if;	
			end if;
		end if;		
		
	end if;	
end if;
end process;

-- ----------------------------------------------------
-- process detect rising edge
-- ----------------------------------------------------
	
	
--	process detect rising edge

label_out_detect_rising_prog_full : process (write_instrument, write_instrument_3_edge) begin
if write_instrument_3_edge = '1' or reset = '1'  then
write_instrument_1	<= '0';
else
	if rising_edge (write_instrument) then
	write_instrument_1	<= '1';
	end if;
end if;
end process;

--	process resynchro rising edge with clk

label_out_detect_rising_1_prog_full : process (clk, reset) begin
if reset = '1' then
write_instrument_2 <= '0';
else
	if rising_edge (clk) then
		if write_instrument_1 = '1' then
		write_instrument_2 <= '1';
		else
		write_instrument_2 <= '0';
		end if;
	end if;
end if;
end process;	

-- meta protection

label_out_detect_rising_2_prog_full : process (clk, reset) begin
if reset = '1' then
write_instrument_3_edge <= '0';
else
	if rising_edge (clk) then
		if write_instrument_2 = '1' then
		write_instrument_3_edge <= '1';
		else
		write_instrument_3_edge <= '0';
		end if;
	end if;
end if;
end process;	



end RTL;