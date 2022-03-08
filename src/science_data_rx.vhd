----------------------------------------------------------------------------------------
--	B.Bertrand
--	19/04/2021

----------------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

library work;
use work.science_data_rx_package.all;

entity science_data_rx is
   port (

	reset_n 			: in std_logic;
	i_clk_science 		: in std_logic;
	
		
	-- Link
	
	i_science_ctrl		:	in	std_logic;
	i_science_data		:	in	std_logic_vector(LinkNumber-1 downto 0);
	data_rate_enable	: 	in std_logic;
	
	-- --	deserialize
	
	--start_data_rate		:	in	std_logic;
	
	--CTRL				:	out	std_logic_vector(7 downto 0);
	-- data_out			:	out	t_ARRAY8bits;
	-- data_ready			:	out	std_logic;
	
	--	fifo 
	
	dataout_instrument		:	out	std_logic_vector(15 downto 0);
	dataout_instrument_wire	:	out	std_logic_vector(15 downto 0);
	write_instrument 		:	out	std_logic	

	
	-- i_c0_science_data    : in    std_logic;                       
    -- i_c1_science_data    : in    std_logic;                       
    -- i_c2_science_data    : in    std_logic;                        
    -- i_c3_science_data    : in    std_logic                         
			
      );

end science_data_rx;

architecture RTL of science_data_rx is

--signal	data_out_wide			:	t_ARRAY16bits(0 to 3);
signal	data_out_wide_process	:	t_ARRAY16bits(0 to 3);
signal	ctrl_out_wide			:	std_logic_vector(15 downto 0);


signal	cpt						:	integer range 0 to 4;
signal	write_data 				:	std_logic;

signal	data_out				:	t_ARRAY8bits;
signal	CTRL					:	std_logic_vector(7 downto 0);
signal	data_ready				:	std_logic;

begin

   -- ------------------------------------------------------------------------------------------------------
   --	deserialyze	data   
   -- ------------------------------------------------------------------------------------------------------

	generate_science_data_rx_fsm : for N in LinkNumber-1 downto 0 generate
		label_science_data_rx_fsm : entity work.science_data_rx_fsm
		Port map (
						-- param
						wd_timeout 		=>	X"FFFF",
						
						-- global	
						
						reset_n			=>	reset_n,
						i_clk_science	=>	i_clk_science,
						data_rate_enable=>	data_rate_enable,
						
						-- Link
						
						i_science_ctrl	=>	i_science_ctrl,
						i_science_data	=>	i_science_data(N),

						-- deserialize
	
						data_out 		=>	data_out(N)


	
						);
	end generate generate_science_data_rx_fsm;

   -- ------------------------------------------------------------------------------------------------------
   --	deserialyze	CTRL and generate ready   
   -- ------------------------------------------------------------------------------------------------------	

		label_ctrl_rx_fsm : entity work.ctrl_rx_fsm
		Port map (
						-- param
						wd_timeout 		=>	X"FFFF",
						
						-- global	
						
						reset_n			=>	reset_n,
						i_clk_science	=>	i_clk_science,
						data_rate_enable=>	data_rate_enable,
						
						-- Link
						
						i_science_ctrl	=>	i_science_ctrl,
					

						-- deserialize
	
						CTRL			=>	CTRL,
						data_ready		=>	data_ready

						);
	
	
	
   -- ------------------------------------------------------------------------------------------------------
   --	16 bit data maker
   -- ------------------------------------------------------------------------------------------------------	
	
-- for_generate_data : for i in 0 to 3 generate
-- data_out_wide(i)	<=	data_out(i+i)&data_out(i+i+1) when 	data_ready = '1' else (others => '0');
-- end generate for_generate_data;	

	
for_generate_process: for i in 0 to ColNumber-1 generate 	
begin
process(reset_n, i_clk_science)
begin
	if reset_n = '0' then 
	data_out_wide_process(i)	<= (others => '0');	
	else
		if i_clk_science = '1' and i_clk_science'event then
			if	data_ready = '1' then
			data_out_wide_process(i)	<=	data_out(2*i)&data_out(2*i+1);
			end if;
		end if;	
	end if;	
end process;
end generate for_generate_process;	

   -- ------------------------------------------------------------------------------------------------------
   --	16 bit CTRL maker
   -- ------------------------------------------------------------------------------------------------------

--ctrl_out_wide	<=	x"AA"&CTRL(0) when 	data_ready = '1' else (others => '0');

   -- ------------------------------------------------------------------------------------------------------
   --	instrument fifo writer
   -- ------------------------------------------------------------------------------------------------------


process(reset_n, i_clk_science)
begin
	if reset_n = '0' then 
	dataout_instrument		<=	(others => '0');
	dataout_instrument_wire	<=	(others => '0');
	write_instrument 	<= '0';
	cpt					<= 0;
	write_data 			<= '0';
	else
		if i_clk_science = '1' and i_clk_science'event then
		write_instrument 	<= '0';
			if	data_ready = '1'  then
			--write_instrument 		<= '1';			--	don't transfert CTRL to GSE
			--dataout_instrument		<=	x"AA"&CTRL;	--	16 bit CTRL maker and write 16 bit CTRL., to wire out USB.
			dataout_instrument_wire	<=	x"AA"&CTRL;
			write_data 				<= '1';
			else
				if	write_data = '1' and cpt < ColNumber then
				cpt	<= cpt + 1;
				dataout_instrument	<=	data_out_wide_process(cpt);	--	write 16 bit data. 
				write_instrument 	<= '1';
				else
				write_instrument 	<= '0';
				cpt					<= 0;
				write_data 			<= '0';		
				end if;	
			end if;
		end if;	
	end if;	
end process;
   

	  
end RTL;