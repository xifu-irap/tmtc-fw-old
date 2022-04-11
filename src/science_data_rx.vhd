----------------------------------------------------------------------------------------
--	B.Bertrand
--	19/04/2021

----------------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use work.science_data_rx_package.all;

entity science_data_rx is
   port (

	reset_n 			: in std_logic;
	i_clk_science 		: in std_logic_vector(LinkNumber-1 downto 0);

	-- test signal -- 
	start_detected : out std_logic_vector(LinkNumber-1 downto 0);
		
	-- Link
	
	i_science_ctrl		:	in	std_logic_vector((ColNumber/2)-1 downto 0);
	i_science_data		:	in	std_logic_vector(LignNumber-1 downto 0);
	data_rate_enable	: 	in std_logic;
	
	--	fifo 
	
	dataout_instrument		:	out	std_logic_vector(127 downto 0);
	write_instrument 		:	out	std_logic	

      );

end science_data_rx;

architecture RTL of science_data_rx is

signal	data_out_wide_process	:	t_ARRAY16bits(0 to 3);
signal	ctrl_out_wide			:	std_logic_vector(15 downto 0);


signal	cpt						:	integer range 0 to 4;
signal  cpt_fifo                :   integer;
signal  cpt_frame               :   integer;
signal	write_data 				:	std_logic;

signal	data_out				:	t_ARRAY8bits;
signal	CTRL					:	t_ARRAY8bits_ctrl;
signal	data_ready				:	std_logic_vector((ColNumber/2)-1 downto 0);

--- Register ----

signal reg_ctrl : t_ARRAY8bits_ctrl;
signal reg_ctrl_r : t_ARRAY8bits_ctrl;
signal reg_ctrl_rr : t_ARRAY8bits_ctrl;
signal reg_data_ready : std_logic_vector (LinkNumber-1 downto 0);
signal reg_data_out : t_ARRAY8bits;
signal reg_data_out_r : t_ARRAY8bits;
signal reg_data_out_rr : t_ARRAY8bits;
signal frame : t_ARRAY96bits(0 to 3);
signal frame_fifo : t_ARRAY128bits (0 to 2);

-- Resynchro signal --
signal start_maker : std_logic;
signal cpt_synchro : std_logic_vector(1 downto 0);

begin

   -- ------------------------------------------------------------------------------------------------------
   --	deserialyze	data   
   -- ------------------------------------------------------------------------------------------------------

   generate_science_data_rx_fsm : for I in LinkNumber - 1 downto 0 generate 
	generate_science_data_rx_fsm_link : for N in (LignNumber/2)-1 downto 0 generate
		label_science_data_rx_fsm : entity work.science_data_rx_fsm
		Port map (
						-- param
						wd_timeout 		=>	X"FFFF",
						
						-- global	
						
						reset_n			=>	reset_n,
						i_clk_science	=>	i_clk_science(I),
						data_rate_enable=>	data_rate_enable,
						
						-- Link
						
						i_science_ctrl	=>	i_science_ctrl(I),
						i_science_data	=>	i_science_data(4*I+N),

						-- deserialize
	
						data_out 		=>	data_out(4*I+N)

						);
		end generate generate_science_data_rx_fsm_link;
	end generate generate_science_data_rx_fsm ;

   -- ------------------------------------------------------------------------------------------------------
   --	deserialyze	CTRL and generate ready   
   -- ------------------------------------------------------------------------------------------------------	

   generate_science_ctrl_rx_fsm : for N in LinkNumber-1 downto 0 generate
		label_ctrl_rx_fsm : entity work.ctrl_rx_fsm
		Port map (
						-- param
						wd_timeout 		=>	X"FFFF",
						
						-- global	
						
						reset_n			=>	reset_n,
						i_clk_science	=>	i_clk_science(N),
						data_rate_enable=>	data_rate_enable,
						
						-- Link
						
						i_science_ctrl	=>	i_science_ctrl(N),

						-- deserialize
						start_detected  => start_detected(N),
						CTRL			=>	CTRL(N),
						data_ready		=>	data_ready(N)

						);
	end generate generate_science_ctrl_rx_fsm;

   -- ------------------------------------------------------------------------------------------------------
   --	Register to maintain the value  
   -- ------------------------------------------------------------------------------------------------------

	reg_generate : for N in LinkNumber-1 downto 0 generate
	ctrl_register : process (reset_n, i_clk_science(N))
		begin 
			if reset_n ='0' then
				reg_ctrl(N) <= (others =>'0');
				reg_data_ready(N) <= '0';
				reg_data_out(4*N) <= (others => '0');
				reg_data_out(4*N+1) <= (others => '0');
				reg_data_out(4*N+2) <= (others => '0');
				reg_data_out(4*N+3) <= (others => '0');
			elsif rising_edge(i_clk_science(N)) then
				if data_ready(N) ='1' then
					reg_ctrl(N) <= CTRL(N);
					reg_data_ready(N) <= data_ready(N);
					reg_data_out(4*N) <= data_out(4*N);
					reg_data_out(4*N+1) <= data_out(4*N+1);
					reg_data_out(4*N+2) <= data_out(4*N+2);
					reg_data_out(4*N+3) <= data_out(4*N+3);
				elsif cpt_synchro = "10" then
					reg_data_ready(N) <= '0';
				end if;
			end if;
		end process;
	end generate reg_generate ;

   -- ------------------------------------------------------------------------------------------------------
   --	Resynchro
   -- ------------------------------------------------------------------------------------------------------	
	
	sync_link : process (reset_n, i_clk_science(0))
	begin 
		if reset_n ='0' then
			reg_ctrl_r <= (others =>(others =>'0'));
			reg_ctrl_rr <= (others =>(others =>'0'));
			reg_data_out_r <= (others =>(others =>'0'));
			reg_data_out_rr <= (others =>(others =>'0'));
			start_maker <='0' ;
			cpt_synchro <= "00" ;
		elsif rising_edge(i_clk_science(0)) then
			start_maker <='0';
			if reg_data_ready = (reg_data_ready'range => '1') then 
				cpt_synchro <= std_logic_vector(unsigned(cpt_synchro) + 1);
				reg_ctrl_r <= reg_ctrl ;
				reg_ctrl_rr <= reg_ctrl_r;
				reg_data_out_r <= reg_data_out ;
				reg_data_out_rr <= reg_data_out_r ;
			end if ;
			if cpt_synchro = "10" then
				start_maker <='1' ;
				cpt_synchro <= "00" ;
			end if;
		end if;
	end process ;

	process(reset_n, i_clk_science(0))
	begin 
		if reset_n ='0' then 
			frame 			     	<=  (others => (others => '0')) ;
			frame_fifo		     	<=  (others => (others => '0')) ;
			dataout_instrument		<=	(others => '0');
			write_instrument 		<= '0';
			write_data              <= '0';
			cpt_frame               <= 0 ;
			cpt_fifo                <= 0 ;
		elsif rising_edge(i_clk_science(0)) then
			if start_maker ='1' then 
				cpt_frame <= cpt_frame + 1;
				frame(cpt_frame) <= x"AAAA" & reg_ctrl_rr(0) & reg_ctrl_rr(1) & reg_data_out_rr(0) & reg_data_out_rr(1) & reg_data_out_rr(2) & reg_data_out_rr(3) & reg_data_out_rr(4) & reg_data_out_rr(5) & reg_data_out_rr(6) & reg_data_out_rr(7);
			end if;
			if cpt_frame = 4 then 
				cpt_frame <= 0;
				frame_fifo(0) <= frame(0) & frame(1)(95 downto 64);
				frame_fifo(1) <= frame(1)(63 downto 0) & frame(2)(95 downto 32);
				frame_fifo(2) <= frame(2)(31 downto 0) & frame(3);
				write_data <= '1';
			end if;
			if write_data = '1' and cpt_fifo <3 then
				cpt_fifo <= cpt_fifo + 1 ;
				dataout_instrument <= frame_fifo(cpt_fifo);
				write_instrument <='1';
			end if;
			if cpt_fifo = 3 then
				write_data <= '0';
				cpt_fifo <= 0;
				write_instrument <='0';
			end if;
		end if ;
	end process;
	
end RTL;



