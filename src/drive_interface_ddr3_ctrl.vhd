----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    07/09/2015 
-- Design Name:    usb_to_fmc
-- Module Name:    drive_interface_ddr3_ctrl - RTL 
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

entity drive_interface_ddr3_ctrl is
		port(
			
		clk			: 	in	STD_LOGIC;
		reset		: 	in	STD_LOGIC;
		
		--	ep20wire			:	out	STD_LOGIC_VECTOR(31 downto 0);
		
		calib_done	: 	in	STD_LOGIC; 
--	//DDR Input Buffer (ib_)
		pipe_in_read		: 	out	STD_LOGIC;	
		pipe_in_data		:	in	STD_LOGIC_VECTOR(127 downto 0);
		pipe_in_rd_count	:	in	STD_LOGIC_VECTOR(7 downto 0);
		pipe_in_valid 		: 	in	STD_LOGIC;
		pipe_in_empty		: 	in	STD_LOGIC;
--	//DDR Output Buffer (ob_)
		pipe_out_write		: 	out	STD_LOGIC;	
		pipe_out_data		:	out	STD_LOGIC_VECTOR(127 downto 0);
		pipe_out_wr_count	:	in	STD_LOGIC_VECTOR(7 downto 0);
		pipe_out_full		: 	in	STD_LOGIC;
	
		app_rdy			: 	in	STD_LOGIC;
		app_en			: 	out	STD_LOGIC;	
		app_cmd			:	out	STD_LOGIC_VECTOR(2 downto 0);
		app_addr		:	out	STD_LOGIC_VECTOR(28 downto 0);
	
		app_rd_data			:	in	STD_LOGIC_VECTOR(127 downto 0);
		app_rd_data_end		: 	in	STD_LOGIC; 
		app_rd_data_valid	: 	in	STD_LOGIC;
	
		app_wdf_rdy			: 	in	STD_LOGIC;
		app_wdf_wren		: 	out	STD_LOGIC;	
		app_wdf_data		:	out	STD_LOGIC_VECTOR(127 downto 0);
		app_wdf_end			: 	out	STD_LOGIC;	
		app_wdf_mask		:	out	STD_LOGIC_VECTOR(15 downto 0);
		
		prog_empty 			: 	in STD_LOGIC;

		load_ep_wire		: 	out	STD_LOGIC;
		fifo_filled			: 	in STD_LOGIC;
		counter_BL_read_DRR3: 	out	STD_LOGIC_VECTOR(31 downto 0);
		
		SYNC_OUT_3			: 	in	STD_LOGIC_VECTOR(31 downto 0);
		
		ddr3_stamp			: 	out	STD_LOGIC_VECTOR(28 downto 0);
		
		buffer_new_cmd_byte_addr_wr :	out	STD_LOGIC_VECTOR(54 downto 0);
		buffer_new_cmd_byte_addr_rd :	out	STD_LOGIC_VECTOR(54 downto 0)
		
--		ack_time_out		: 	out	STD_LOGIC
		
--		time_out			: 	in STD_LOGIC
		


	
		);
end entity;

architecture RTL of drive_interface_ddr3_ctrl is

--	fsm manager

type FSM_State_manager is (idle, write_ddr3, read_ddr3, wait_restart);		
signal state_manager	: FSM_State_manager;

--signal signal_counter_BL_read_DRR3	:	STD_LOGIC_VECTOR(31 downto 0);

--signal counter_data_writed	:	STD_LOGIC_VECTOR(31 downto 0);

--	fsm_interface

constant FIFO_SIZE           : integer	:= 256;
constant BURST_UI_WORD_COUNT : integer	:= 2;--'d1; //(WORD_SIZE*BURST_MODE/UI_SIZE) = BURST_UI_WORD_COUNT : 16*8/128 = 1



constant ADDRESS_INCREMENT   :	STD_LOGIC_VECTOR(4 downto 0) := b"01000";--'d8; // UI Address is a word address. BL8 Burst Mode = 8.  Memory Width = 16.

signal	cmd_byte_addr_wr	:	STD_LOGIC_VECTOR(57 downto 0);

signal	new_cmd_byte_addr_wr:	STD_LOGIC_VECTOR(54 downto 0);

signal	new_cmd_byte_addr_rd:	STD_LOGIC_VECTOR(54 downto 0);
signal	cmd_byte_addr_rd	:	STD_LOGIC_VECTOR(57 downto 0);

signal	write_mode	:	STD_LOGIC;
signal	ack_write_mode	:	STD_LOGIC;
signal	read_mode	:	STD_LOGIC;
signal	ack_read_mode	:	STD_LOGIC;
--signal	reset_d		:	STD_LOGIC;

type FSM_State is ( s_idle, s_write_0, s_write_1, s_write_2, s_write_3, s_write_4, s_read_0, s_read_1, s_read_2, s_read_3);		
signal state		: FSM_State;

--signal DATA_0	  		: std_logic_vector(255 downto 0);

--	manage ep wire


signal max_readed_rest		:	STD_LOGIC_VECTOR(3 downto 0);
signal cnt_readed_rest		:	STD_LOGIC_VECTOR(3 downto 0);

signal signal_app_en		:	STD_LOGIC;
signal signal_load_ep_wire	:	STD_LOGIC;

signal counter_wait_dump_ddr3	: integer;

begin
 
app_wdf_mask <= x"0000";

app_en 						<= signal_app_en; 
buffer_new_cmd_byte_addr_wr	<= new_cmd_byte_addr_wr;
buffer_new_cmd_byte_addr_rd	<= new_cmd_byte_addr_rd;  




----------------------------------------
--	fsm_fsm_manager
-----------------------------------------  
fsm_manager	:	process(reset, clk)
begin
if reset = '1'
then 
state_manager	<= idle;
write_mode 	<=	'0';
read_mode	<=	'0'; 
--counter_data_writed <= (others => '0');
--counter_BL_read_DRR3	<= (others => '0');
--signal_counter_BL_read_DRR3	<= (others => '0');

max_readed_rest <= (others => '0');
--ack_time_out	<=	'0'; 
--counter_wait_dump_ddr3 <= 0;

else
	if clk = '1' and clk'event
	then 
 
	signal_load_ep_wire <= '0';
--	ack_time_out	<=	'0'; 
	
		case state_manager is
			
			 when	idle		=>
									if calib_done = '1' then
									

											if prog_empty = '1' and (new_cmd_byte_addr_wr /= new_cmd_byte_addr_rd) and pipe_out_full = '0'    then
											state_manager	<= read_ddr3;
											else
											state_manager	<= write_ddr3;
											end if;
										
																			
									end if;
									
											
			when	write_ddr3	=>
			
									if	write_mode = '0'  then
										if	(prog_empty = '0' or (new_cmd_byte_addr_wr = new_cmd_byte_addr_rd) or pipe_out_full = '1') and pipe_in_empty = '0'
										then
										read_mode	<=	'0';
										write_mode 	<=	'1';			--	remote write in ddr3
										else
										state_manager	<= idle;		-- write ddr3 not needed
										end if;
									else
									state_manager	<= write_ddr3; --	wait last ack before idle
									end if;							
										
									if ack_write_mode = '1' and write_mode = '1' then	--	ack data writed in ddr3
									write_mode 	<=	'0';
									read_mode	<=	'0'; 

									end if;
										
			
			when	read_ddr3	=>
			
									if  read_mode = '0'  then
										if	prog_empty = '1' and pipe_out_full = '0' then
										read_mode	<=	'1';		
										write_mode 	<=	'0';
											if (new_cmd_byte_addr_wr = new_cmd_byte_addr_rd) then
											--	write and read adress is same
											max_readed_rest <= (others => '0');
											--signal_counter_BL_read_DRR3 <= signal_counter_BL_read_DRR3;
											state_manager	<= idle;
											read_mode	<=	'0';	
											else
												if (new_cmd_byte_addr_wr - new_cmd_byte_addr_rd) < x"4"
												then
												--	write and read adress is almost same											
												max_readed_rest <= new_cmd_byte_addr_wr(3 downto 0) - new_cmd_byte_addr_rd(3 downto 0);
												--signal_counter_BL_read_DRR3 <= signal_counter_BL_read_DRR3 + (new_cmd_byte_addr_wr(1 downto 0) - new_cmd_byte_addr_rd(1 downto 0));
												else
												--	default mode read
												max_readed_rest <= x"4";
												--signal_counter_BL_read_DRR3 <= signal_counter_BL_read_DRR3 + 4;
												end if;
											end if;
										else
										state_manager	<= idle;		-- read ddr3 not needed 
										end if;
									else
									state_manager	<= read_ddr3;	--	wait last ack read before idle
									end if;	
										
									--	ack data readed in ddr3		
									
									if 	ack_read_mode = '1' and read_mode = '1'  then	
									read_mode	<=	'0';			
									write_mode 	<=	'0';			
									end if;	

		

									
									
			when others 		=>
			
		end case;	   
	end if;
end if;
end process;

--------------------------------------------
--	fsm_interface	
---------------------------------------------
fsm_interface	:	process(reset, clk)
begin
if reset = '1'
then
state             <= s_idle;
cmd_byte_addr_wr  <= (others => '0'); 
cmd_byte_addr_rd  <= (others => '0'); 
signal_app_en            <= '0';
app_cmd           <= b"000";
app_addr          <= (others => '0'); 
app_wdf_wren      <= '0';
app_wdf_end       <= '0';
ack_write_mode		<= '0';	
ack_read_mode		<= '0';
pipe_in_read      <= '0';
pipe_out_write    <= '0';
pipe_out_data	<= (others => '0'); 
app_wdf_data	<= (others => '0');
--old_cmd_byte_addr_rd <= (others => '0');
new_cmd_byte_addr_rd <= (others => '0');
--old_cmd_byte_addr_wr <= (others => '0');
new_cmd_byte_addr_wr <= (others => '0');
cnt_readed_rest	<= (others => '0');

else
	if clk = '1' and clk'event
	then
	signal_app_en            <= '0';
	app_wdf_wren      <= '0';
	app_wdf_end       <= '0';
	pipe_in_read      <= '0';
	pipe_out_write    <= '0';
	ack_write_mode		<= '0';	
	ack_read_mode		<= '0';
	
		case state is
		
			when	s_idle		=>
	
								-- if state_manager = fifo_empty then
								-- old_cmd_byte_addr_rd <= (others => '0');
								-- old_cmd_byte_addr_wr <= (others => '0');
								-- cmd_byte_addr_wr  <= (others => '0'); 
								-- cmd_byte_addr_rd  <= (others => '0');
								
								-- end if;
								
								if ( calib_done = '1' and write_mode = '1' ) then	-- read data in pipe_in and write ddr3
								app_addr <= cmd_byte_addr_wr(28 downto 0);	-- boundary ddr3 adress on 11 bits
								state 	<= s_write_0;
								--ack_write_mode		<= '1';	
								else 
									if ( calib_done = '1' and read_mode = '1'  ) then --read data in ddr3 and write in pipe out
									app_addr <= cmd_byte_addr_rd(28 downto 0);	-- boundary ddr3 adress on 11 bits
									state <= s_read_0;	
									--ack_read_mode		<= '1';
									end if;
								end if;
							
			when	s_write_0	=>
									state <= s_write_1;		-- read data in pipe in
									pipe_in_read <= '1';
									
			when	s_write_1	=>
			
									if pipe_in_valid = '1' then		--	 transfer data on ddr3 bus
									app_wdf_data <= pipe_in_data;
									state 		<= s_write_2;
									end if;
			
			when	s_write_2	=>
									
									if app_wdf_rdy = '1' then
									state <= s_write_3;
									end	if;
			
			when	s_write_3	=>	-- write data in ddr3
			
									app_wdf_wren <= '1';
									app_wdf_end <= '1';
																		
									if (app_wdf_rdy =  '1')  then	--	acknowledge data is writed in ddr3
										signal_app_en    <= '1';
										app_cmd <= b"000";
										state <= s_write_4;	
										ack_write_mode		<= '1';	-- disable remote write				
									end if;
			
			when	s_write_4	=>	-- increment address
								
									if (app_rdy = '1') then
									cmd_byte_addr_wr <= cmd_byte_addr_wr + ADDRESS_INCREMENT;	--	set address data for next remote write
									new_cmd_byte_addr_wr <= cmd_byte_addr_wr(57 downto 3) + 1;
									--old_cmd_byte_addr_wr <= cmd_byte_addr_wr(57 downto 3) + 1;	--	last address data writed
									state <= s_idle;		
									else 
									signal_app_en    <= '1';
									app_cmd <= b"000";
									end if;
									
			when	s_read_0	=>	-- read data in ddr3
			
									signal_app_en    <= '1';	-- launch first read
									app_cmd <= b"001";
									state <= s_read_1;	
									cnt_readed_rest	<= (others => '0');									

			when	s_read_1	=>
			
									if app_rdy = '0' and  signal_app_en = '1' then	--	previous read data don't work, relaunch read
									signal_app_en    <= '1';
									else
										if cnt_readed_rest < max_readed_rest-1  then
											if (app_rdy = '1') then					-- launch one read
											app_addr <= cmd_byte_addr_rd(28 downto 0) + ADDRESS_INCREMENT; -- boundary ddr3 adress on 11 bits
											cmd_byte_addr_rd <= cmd_byte_addr_rd + ADDRESS_INCREMENT;
											signal_app_en    <= '1';	
											cnt_readed_rest <= cnt_readed_rest + 1;
											
											else 
											signal_app_en    <= '1';
											app_cmd <= b"001";
											end if;
										else
										--old_cmd_byte_addr_rd <= cmd_byte_addr_rd(57 downto 3) + 1;	--	last address data readed
										cmd_byte_addr_rd <= cmd_byte_addr_rd + ADDRESS_INCREMENT;	--	set address data for next remote read
										new_cmd_byte_addr_rd <= cmd_byte_addr_rd(57 downto 3) + 1;
										state <= s_read_2;
										cnt_readed_rest	<= (others => '0');
										end if;
									end if;
											
			when	s_read_2	=>	if cnt_readed_rest <= max_readed_rest-1 then
										if (app_rd_data_valid = '1') then	--	incoming valid data	
										pipe_out_data <= app_rd_data;
										pipe_out_write <= '1';		--	write data pipe out						
										cnt_readed_rest <= cnt_readed_rest + 1;
										end if;	
									else
										
										state <= s_read_3;
										cnt_readed_rest	<= (others => '0');
										ack_read_mode		<= '1';		-- disable remote read
										
											
									end if;
																		
			 when	s_read_3	=>

									state <= s_idle;
															
									
			when others 		=>
			
		end case;	     	      		
	
	end if;
end if;
end process;


-- ila_inst_2 : entity work.ILA
-- port map (
  -- clk     	=> 	clk,
-- --  DATA		=>	DATA,
  -- trig0   	=> 	DATA_0,
  -- control 	=> 	CONTROL2
-- ); 




-- DATA_0(255 downto 36) 	<= (others => '0');
-- DATA_0(35 downto 4) <=	counter_data_writed; 	
-- DATA_0(3) <=	ack_read_mode;
-- DATA_0(2) <=	read_mode; 	
-- DATA_0(1) <=	ack_write_mode; 	
-- DATA_0(0) <=	write_mode;	
	
		
end RTL;