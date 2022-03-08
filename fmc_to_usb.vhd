----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    01/10/2015 
-- Design Name:    usb_to_fmc
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
use ieee.numeric_std.all;


--use work.okLibrary.all;
library work ;
use work.FRONTPANEL.all;
use work.science_data_rx_package.all;
use work.pkg_func_math.all;
use work.pkg_project_ok.all;
use work.pkg_project.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.Ramtest_pack.all;

entity fmc_to_usb is
		port(
		
		--	global
				
		okUH      : in     STD_LOGIC_VECTOR(4 downto 0);
		okHU      : out    STD_LOGIC_VECTOR(2 downto 0);
		okUHU     : inout  STD_LOGIC_VECTOR(31 downto 0);
		okAA      : inout  STD_LOGIC;
		
		sys_clkp	: in	STD_LOGIC;								-- input	  wire         sys_clkp,
		sys_clkn	: in 	STD_LOGIC;								-- input  wire         sys_clkn,
		
		led       : out    STD_LOGIC_VECTOR(3 downto 0);
		
		ddr3_dq		: inout	STD_LOGIC_vector (DQ_WIDTH-1  downto 0);-- inout  wire [DQ_WIDTH-1:0]                 ddr3_dq,	//16
		ddr3_addr	: out   STD_LOGIC_vector (ROW_WIDTH-1  downto 0);			-- output wire [ROW_WIDTH-1:0]                ddr3_addr,	//15
		ddr3_ba		: out   STD_LOGIC_vector (BANK_WIDTH-1  downto 0);	-- output wire [BANK_WIDTH-1:0]               ddr3_ba,		//3
		ddr3_ck_p	: out   STD_LOGIC_vector (CK_WIDTH-1  downto 0);-- output wire [CK_WIDTH-1:0]                 ddr3_ck_p,	//1
		ddr3_ck_n	: out   STD_LOGIC_vector (CK_WIDTH-1  downto 0);-- output wire [CK_WIDTH-1:0]                 ddr3_ck_n,
		ddr3_cke	: out   STD_LOGIC_vector (CKE_WIDTH-1  downto 0);-- output wire [CKE_WIDTH-1:0]                ddr3_cke,	//1	
		ddr3_cs_n	: out   STD_LOGIC_vector ((CS_WIDTH*nCS_PER_RANK)-1  downto 0);-- output wire [(CS_WIDTH*nCS_PER_RANK)-1:0]  ddr3_cs_n,
		ddr3_cas_n	: out   STD_LOGIC;							-- output wire                                ddr3_cas_n,
		ddr3_ras_n	: out   STD_LOGIC;							-- output wire                                ddr3_ras_n,
		ddr3_we_n	: out   STD_LOGIC;							-- output wire                                ddr3_we_n,
		ddr3_odt	: out   STD_LOGIC_vector ((CS_WIDTH*nCS_PER_RANK)-1  downto 0);-- output wire [(CS_WIDTH*nCS_PER_RANK)-1:0]  ddr3_odt,
		ddr3_dm		: out   STD_LOGIC_vector (DM_WIDTH-1  downto 0);-- output wire [DM_WIDTH-1:0]                 ddr3_dm,	//2
		ddr3_dqs_p	: inout	STD_LOGIC_vector (DQS_WIDTH-1  downto 0);-- inout  wire [DQS_WIDTH-1:0]                ddr3_dqs_p,	//2
		ddr3_dqs_n	: inout	STD_LOGIC_vector (DQS_WIDTH-1  downto 0);-- inout  wire [DQS_WIDTH-1:0]                ddr3_dqs_n,
		ddr3_reset_n: out   STD_LOGIC;	-- output wire                                ddr3_reset_n

		--	from NG-LARGE	
		
		clk_science_p			: 	in	STD_LOGIC;
		clk_science_n			: 	in	STD_LOGIC;
		
		i_science_ctrl_p		:	in	STD_LOGIC;
		i_science_ctrl_n		:	in	STD_LOGIC;
		
		i_science_data_p		:	in	STD_LOGIC_VECTOR(LinkNumber-1 downto 0);
		i_science_data_n		:	in	STD_LOGIC_VECTOR(LinkNumber-1 downto 0);
			
		-- Paul Test -- 
		i_miso : in std_logic ;
		o_mosi : out std_logic;
		o_sclk : out std_logic;
		o_sync_n : out std_logic 
		);
end entity;

architecture RTL of fmc_to_usb is

	signal Clk				: std_logic;
	signal rst				: STD_LOGIC;
	signal reset			: STD_LOGIC;
	signal reset_n			: STD_LOGIC;
	signal rst_meta			: STD_LOGIC;
	signal rst_a			: STD_LOGIC;	

	--	okHost

	signal okClk			: STD_LOGIC;

	signal okHE				: STD_LOGIC_VECTOR(112 downto 0);
	signal okEH				: STD_LOGIC_VECTOR(64 downto 0);

	--	okWireOR

	signal okEHx			: std_logic_vector(65*11-1 downto 0); 

	-- fifo instrument

	signal read_instrument	: STD_LOGIC;
	signal empty_fifo_instrument: STD_LOGIC;

	signal full_fifo_instrument 	: STD_LOGIC;
	signal full_fifo_instrument_1	: STD_LOGIC;
	signal full_fifo_instrument_2	: STD_LOGIC;
	signal enable_debug				: STD_LOGIC;

	signal valid_fifo_instrument: STD_LOGIC;
	signal dataout_instrument 		: STD_LOGIC_VECTOR(15 downto 0);
	signal dataout_instrument_wire	: STD_LOGIC_VECTOR(15 downto 0);
	signal write_instrument	: STD_LOGIC;
	signal load_MSB			: STD_LOGIC;

	signal data_instrument	: STD_LOGIC_VECTOR(127 downto 0);

	signal din					: STD_LOGIC_VECTOR(31 downto 0);
	signal wr_en				: STD_LOGIC;

	--	okPipeIn_fifo

	signal read_sended		: STD_LOGIC;
	signal pi0_ep_write		: STD_LOGIC;
	signal pi0_ep_dataout	: STD_LOGIC_VECTOR(31 downto 0);
	signal pipe_in_read		: STD_LOGIC;
	signal pipe_in_data		: STD_LOGIC_VECTOR(31 downto 0);
	signal pipe_in_data_use : STD_LOGIC_VECTOR(31 downto 0);
	signal pipe_in_rd_count	: STD_LOGIC_VECTOR(7 downto 0); 
	signal pipe_in_wr_count	: STD_LOGIC_VECTOR(9 downto 0);
	signal pipe_in_empty	: STD_LOGIC;
	signal pipe_in_full		: STD_LOGIC;
	signal pipe_in_valid	: STD_LOGIC;

	--	okPipeOut_fifo	

	signal po0_ep_read		: STD_LOGIC;
	signal po0_ep_datain	: STD_LOGIC_VECTOR(31 downto 0);
	signal pipe_out_write	: STD_LOGIC;
	signal pipe_out_data	: STD_LOGIC_VECTOR(127 downto 0);
	signal pipe_out_rd_count: STD_LOGIC_VECTOR(9 downto 0);
	signal pipe_out_wr_count: STD_LOGIC_VECTOR(7 downto 0);
	signal pipe_out_full		: STD_LOGIC;
	signal pipe_out_empty		: STD_LOGIC;
	signal empty					: STD_LOGIC;
	signal wr_data_count	: STD_LOGIC_VECTOR(14 downto 0);
	signal rd_data_count	: STD_LOGIC_VECTOR(16 downto 0);	

	--	wire 

	signal ep00wire        	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep20wire			: STD_LOGIC_VECTOR(31 downto 0);
	signal ep22wire			: STD_LOGIC_VECTOR(31 downto 0);
	signal ep25wire			: STD_LOGIC_VECTOR(31 downto 0);
	signal ep26wire			: STD_LOGIC_VECTOR(31 downto 0);
	signal ep27wire			: STD_LOGIC_VECTOR(31 downto 0);
	signal ep28wire			: STD_LOGIC_VECTOR(31 downto 0);


	signal ep20wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep20wire_two 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep20wire_three	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep23wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep23wire_two 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep22wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep22wire_two 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep24wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep24wire_two 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep25wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep25wire_two 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep26wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep26wire_two 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep27wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep27wire_two 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep28wire_one 	: STD_LOGIC_VECTOR(31 downto 0);
	signal ep28wire_two 	: STD_LOGIC_VECTOR(31 downto 0);



	--	ddr3 stamp

	signal ep23wire						: STD_LOGIC_VECTOR(31 downto 0);
	signal ep24wire						: STD_LOGIC_VECTOR(31 downto 0);
	signal buffer_new_cmd_byte_addr_rd	: STD_LOGIC_VECTOR(54 downto 0);
	signal buffer_new_cmd_byte_addr_wr	: STD_LOGIC_VECTOR(54 downto 0);
	signal Subtraction_addr_wr_addr_rd	: STD_LOGIC_VECTOR(54 downto 0);



	--	ddr3 interconnect

	--	
	signal	init_calib_complete	: STD_LOGIC;
	signal	sys_rst				: STD_LOGIC;
	signal 	rst_cnt				: STD_LOGIC_VECTOR	(3 downto 0);
	--	

	signal app_ecc_multiple_err	: STD_LOGIC_VECTOR(2*nCK_PER_CLK-1 downto 0);
	signal app_addr				: STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
	signal app_cmd				: STD_LOGIC_VECTOR	(2 downto 0);
	signal app_en				: STD_LOGIC;
	signal app_rdy				: STD_LOGIC;
	signal app_rd_data			: STD_LOGIC_VECTOR	(APP_DATA_WIDTH-1 downto 0);
	signal app_rd_data_end		: STD_LOGIC;
	signal app_rd_data_valid	: STD_LOGIC;
	signal app_wdf_data			: STD_LOGIC_VECTOR	(APP_DATA_WIDTH-1 downto 0);
	signal app_wdf_end			: STD_LOGIC;
	signal app_wdf_mask			: STD_LOGIC_VECTOR	(APP_MASK_WIDTH-1 downto 0);
	signal app_wdf_rdy			: STD_LOGIC;
	signal app_wdf_wren			: STD_LOGIC;

	--	led	
		
	signal count				: integer;			
	signal led_temp				: STD_LOGIC_VECTOR(3 downto 0);	

	--	icon et ila

	signal CONTROL0 		: std_logic_vector(35 downto 0);
	signal CONTROL1 		: std_logic_vector(35 downto 0);
	signal CONTROL2			 : std_logic_vector(35 downto 0);
	-- signal CONTROL3			 : std_logic_vector(35 downto 0);
	-- signal CONTROL4			 : std_logic_vector(35 downto 0);
	-- signal DATA_0	  		: std_logic_vector(255 downto 0);
	-- signal DATA_1			: std_logic_vector(255 downto 0);
	signal DATA				: STD_LOGIC_VECTOR(1 downto 0);
	signal SYNC_OUT		: std_logic_vector(31 downto 0);	
	signal SYNC_OUT_one	: std_logic_vector(31 downto 0);
	signal SYNC_OUT_fast		: std_logic_vector(31 downto 0);	
	signal start_stop_fast		: STD_LOGIC;
	signal start_stop_one		: STD_LOGIC;
	signal SYNC_OUT_3		: std_logic_vector(31 downto 0);
	signal tREFI_std		: std_logic_vector(31 downto 0);
	signal counter_tREFI_std: std_logic_vector(31 downto 0);

	--	refresh process

	signal tREFI			: integer;
	signal app_ref_req		: STD_LOGIC;
	signal app_ref_ack		: STD_LOGIC;
	signal app_ref_ack_received	: STD_LOGIC;
		


	-- simulate data rate by counter

	signal simulate_data_instrument : STD_LOGIC_VECTOR(31 downto 0);
	signal timer_instrument : integer range 0 to 10002;

	signal first_data			: STD_LOGIC;

	-- manage ep20wire

	signal counter_BL_read_DRR3	:	STD_LOGIC_VECTOR(31 downto 0);
	signal load_ep_wire			: 	STD_LOGIC;
	signal fifo_filled			: 	STD_LOGIC;
	signal signal_empty_fast	: 	STD_LOGIC;

	signal prog_full 		: STD_LOGIC;		
	signal prog_empty		: STD_LOGIC; 

	signal before_prog_full 	: STD_LOGIC;
	signal before_prog_empty 	: STD_LOGIC;

			--	output

	signal ack_time_out		: 	STD_LOGIC;		
	signal time_out				: STD_LOGIC;

	signal clk_slow			: 	STD_LOGIC;

	signal signal_read_piper_out	:	STD_LOGIC_VECTOR(31 downto 0);

	--	HK

	signal pipe_out_data_hk		:	std_logic_vector(31 downto 0);
	signal pipe_out_write_hk	:	STD_LOGIC;
	signal empty_hk				:	STD_LOGIC;
	signal pipe_out_full_hk		:	STD_LOGIC;

	signal po0_ep_read_hk		:	STD_LOGIC;
	signal po0_ep_datain_hk		:	std_logic_vector(31 downto 0);
	signal rd_data_count_hk		:	std_logic_vector(9 downto 0);

	--

	signal init_calib_complete_one		: 	STD_LOGIC;
	signal init_calib_complete_fast		: 	STD_LOGIC;

	signal ep00wire_one					: 	STD_LOGIC;
	signal ep00wire_fast				: 	STD_LOGIC;

	signal start						: 	STD_LOGIC;
	signal start_one					: 	STD_LOGIC;
	signal start_fast					: 	STD_LOGIC;

	-- NG-LARGE

	signal	start_data_rate				: 	STD_LOGIC;
	signal	clk_ng_large				: 	STD_LOGIC;
	signal	clk_ng_large_n				: 	STD_LOGIC;
	signal	ok_pattern					:	t_sc_data_w(0 to c_DMX_NB_COL*c_SC_DATA_SER_NB);

	signal	i_science_data_tx_ena		:	std_logic;
	signal	start_pattern				:	std_logic;
	signal	data_rate_enable			:	std_logic;

	-- Paul Part --

	signal sys_clk : std_logic;
	signal i_science_ctrl : std_logic;
	signal clk_science : std_logic;
	signal i_science_data : std_logic_vector(LinkNumber - 1 downto 0); 

	constant c_SPI_SER_WD_S_V_S   : integer := log2_ceil(c_DAC_SPI_SER_WD_S+1)                                  ; --! DAC SPI: Serial word size vector bus size
	constant c_DAC_SPI_SER_WD_S_V : std_logic_vector(c_SPI_SER_WD_S_V_S-1 downto 0) :=
									std_logic_vector(to_unsigned(c_DAC_SPI_SER_WD_S, c_SPI_SER_WD_S_V_S))       ; --! DAC SPI: Serial word size vector
	--signal o_data : std_logic_vector(31 downto 0);

	component spi_mgt
		Port( i_rst                : in     std_logic                                         ; --! Reset asynchronous assertion, synchronous de-assertion ('0' = Inactive, '1' = Active)
		i_clk              : in     std_logic                                         ; --! System Clock
		i_spi_data_tx          : in     std_logic_vector(c_DAC_SPI_SER_WD_S-1 downto 0)   ; --! Data to transmit
		i_miso               : in     std_logic                                         ; --! Serial data Master in Slave Out
		i_fifo_empty         : in     std_logic                                         ; --! Fifo State (Empty = '1', not Empty ='0') 

		o_read_en                : out    std_logic;                                      --! Read Fifo next value                    
		o_data_ready             : out    std_logic;
		o_data                   : out    std_logic_vector(c_DAC_SPI_SER_WD_S-1 downto 0)                                                                 ;   --! DAC - Serial Data
		o_mosi                   : out    std_logic;
		o_sclk                   : out    std_logic;   --! Serial Clock
		o_sync_n                 : out    std_logic    --! Frame Synchronization ('0' = Active, '1' = Inactive)
	);
	end component ;

begin

GEN_IBUFDS : for i in 0 to LinkNumber - 1 generate
IBUFDS_i :IBUFDS
port map (
      O => i_science_data(i),  -- Buffer output
      I => i_science_data_p(i),  -- Diff_p buffer input (connect directly to top-level port)
      IB => i_science_data_n(i) -- Diff_n buffer input (connect directly to top-level port)
   );
end generate ;

IBUFDS_science_ctrl : IBUFDS 
port map (
      O => i_science_ctrl,  -- Buffer output
      I => i_science_ctrl_p,  -- Diff_p buffer input (connect directly to top-level port)
      IB => i_science_ctrl_n -- Diff_n buffer input (connect directly to top-level port)
   );
	
IBUFDS_clk_science : IBUFDS 
port map (
      O => clk_science,  -- Buffer output
      I => clk_science_p,  -- Diff_p buffer input (connect directly to top-level port)
      IB => clk_science_n -- Diff_n buffer input (connect directly to top-level port)
   );
	

spi_mgt1 : spi_mgt
	port map 
	( i_rst        =>   rst,          
	i_clk          =>   clk,       
	i_spi_data_tx  =>   pipe_in_data,   
	i_miso         =>   i_miso,     
	i_fifo_empty   =>   pipe_in_empty,     

	o_read_en      =>   pipe_in_read,                          
	o_data_ready   =>   pipe_out_write_hk,     
	o_data         =>   pipe_out_data_hk,          
	o_mosi         =>   o_mosi,
	o_sclk         =>   o_sclk,          
	o_sync_n       =>   o_sync_n          
);

----------------------------------------------------
--	LED
----------------------------------------------------   
 
led(3 downto 0) <= led_temp;

process (clk, reset) begin
if reset = '1' then
count <= 0;
else
	if rising_edge(clk) then 
	count <= count + 1;
		if count = 10000000 then
		led_temp(0) <= not led_temp(0);
		led_temp(1) <= not led_temp(1);
		led_temp(2) <= not led_temp(2);
		led_temp(3) <= not led_temp(3);
		count <= 0;
		end if;
	end if;
end if;
end process;
 
----------------------------------------------------
--	RESET
----------------------------------------------------  
 
reset <= ep00wire(0) or rst or SYNC_OUT(0);    --or SYNC_OUT_fast(0);  
  
----------------------------------------------------
--	Controller DDR3
---------------------------------------------------- 
 
label_ddr3_256_16 : ddr3_256_16     
generic map (
	
     PAYLOAD_WIDTH                 	 =>	PAYLOAD_WIDTH,	
     BANK_WIDTH                      =>	BANK_WIDTH,
	 DQ_WIDTH                        =>	DQ_WIDTH,
	 DQS_WIDTH                       =>	DQS_WIDTH,
	 ROW_WIDTH                       =>	ROW_WIDTH,
     CK_WIDTH                        =>	CK_WIDTH,
	 CKE_WIDTH                       =>	CKE_WIDTH,
     CS_WIDTH                        =>	CS_WIDTH,
	 DM_WIDTH                        =>	DM_WIDTH,
     nCS_PER_RANK                    =>	nCS_PER_RANK,
	 ODT_WIDTH                       =>	ODT_WIDTH,
	 ADDR_WIDTH                      =>	ADDR_WIDTH,
	 nCK_PER_CLK                     =>	nCK_PER_CLK
--	 tREFI							 => tREFI
	
	) 
port map (
--// Memory interface ports
--		tREFI						=> 	tREFI,
       ddr3_addr                	=>  ddr3_addr,
       ddr3_ba                      =>  ddr3_ba,
       ddr3_cas_n                   =>  ddr3_cas_n,
       ddr3_ck_n                    =>  ddr3_ck_n,
       ddr3_ck_p                    =>  ddr3_ck_p,
       ddr3_cke                     =>  ddr3_cke,
       ddr3_ras_n                   =>  ddr3_ras_n,
       ddr3_reset_n                 =>  ddr3_reset_n,
       ddr3_we_n                    =>  ddr3_we_n,
       ddr3_dq                      =>  ddr3_dq,
       ddr3_dqs_n                   =>  ddr3_dqs_n,
       ddr3_dqs_p                   =>  ddr3_dqs_p,
       init_calib_complete          =>  init_calib_complete,
      
       ddr3_cs_n                    =>  ddr3_cs_n,
       ddr3_dm                      =>  ddr3_dm,
       ddr3_odt                     =>  ddr3_odt,
--// Application interface ports
       app_addr                     =>  app_addr,
       app_cmd                      =>  app_cmd,
       app_en                       =>  app_en,
       app_wdf_data                 =>  app_wdf_data,
       app_wdf_end                  =>  app_wdf_end,
       app_wdf_wren                 =>  app_wdf_wren,	
       app_rd_data                  =>  app_rd_data,
       app_rd_data_end              =>  app_rd_data_end,
       app_rd_data_valid            =>  app_rd_data_valid,
       app_rdy                      =>  app_rdy,
       app_wdf_rdy                  =>  app_wdf_rdy,
		app_sr_req                	=>   '0',
       app_sr_active                =>  open,
       app_ref_req                  =>  '0',
       app_ref_ack                  =>  open,
       app_zq_req                   =>  '0',
       app_zq_ack                   =>  open,
       ui_clk                       =>  clk,
       ui_clk_sync_rst              =>  rst,
      
       app_wdf_mask                 =>  app_wdf_mask,
       
--// System Clock Ports
       sys_clk_p                    =>   sys_clkp,
       sys_clk_n                    =>   sys_clkn,
      
       sys_rst                      =>  sys_rst
);
 
	--//MIG Infrastructure Reset
process (okClk) begin
	if rising_edge(okClk) then
		if(rst_cnt < "1000") then
		rst_cnt <= rst_cnt + 1;
		sys_rst <= '1';
		else
		sys_rst <= '0';
		end if;
	end if;
end process;
 
icon_inst : entity work.iCON_1
	Port map (
		CONTROL0 => CONTROL0
--		CONTROL1 => CONTROL1
	 );

----------------------------------------------------
--	VIO
----------------------------------------------------

vio_start_rest : entity work.vio
port map (
    CONTROL => CONTROL0,
	clk     => 	clk,
    SYNC_OUT => SYNC_OUT
	 );
	 
----------------------------------------------------
--	Controller DDR3
----------------------------------------------------

label_drive_interface_ddr3_ctrl :	drive_interface_ddr3_ctrl 
port map (

	clk                =>	clk,
	reset              =>	reset,

	--	ep20wire		   =>	ep20wire,	
	
	calib_done         =>	init_calib_complete, 

	pipe_in_read	   =>	read_instrument,
	pipe_in_data       =>	data_instrument,
	pipe_in_rd_count   =>	x"00",
	pipe_in_valid      =>	valid_fifo_instrument,
	pipe_in_empty      =>	empty_fifo_instrument,
	
	pipe_out_write     =>	pipe_out_write,
	pipe_out_data      =>	pipe_out_data,
	pipe_out_wr_count  =>	pipe_out_wr_count,
	pipe_out_full      =>	pipe_out_full,
	
	app_rdy            =>	app_rdy,	--: STD_LOGIC;
	app_en             =>	app_en,		--: STD_LOGIC
	app_cmd            =>	app_cmd,	--: STD_LOGIC_VECTOR	(2 downto 0);
	app_addr           =>	app_addr,	--: STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);	--ADDR_WIDTH            : integer := 29;
	
	app_rd_data        =>	app_rd_data,	--: STD_LOGIC_VECTOR	(APP_DATA_WIDTH-1 downto 0);	--constant APP_DATA_WIDTH        :	integer	:= 128;
	app_rd_data_end    =>	app_rd_data_end,	--: STD_LOGIC;
	app_rd_data_valid  =>	app_rd_data_valid,	--: STD_LOGIC;
	
	app_wdf_rdy        =>	app_wdf_rdy,	--: STD_LOGIC;
	app_wdf_wren       =>	app_wdf_wren,	--: STD_LOGIC;
	app_wdf_data       =>	app_wdf_data,	--: STD_LOGIC_VECTOR	(APP_DATA_WIDTH-1 downto 0);	--constant APP_DATA_WIDTH        :	integer	:= 128;
	app_wdf_end        =>	app_wdf_end,	--: STD_LOGIC;
	app_wdf_mask       =>	app_wdf_mask,	--: STD_LOGIC_VECTOR	(APP_MASK_WIDTH-1 downto 0);	--constant APP_DATA_WIDTH        :	integer	:= 128;

   prog_empty 			=>	prog_empty,
	
	load_ep_wire		=>	load_ep_wire,
	fifo_filled			=>	fifo_filled,
	counter_BL_read_DRR3=>	counter_BL_read_DRR3,	
	
	SYNC_OUT_3		   =>   SYNC_OUT_3,
	
	buffer_new_cmd_byte_addr_wr =>	buffer_new_cmd_byte_addr_wr,
	buffer_new_cmd_byte_addr_rd =>	buffer_new_cmd_byte_addr_rd
	
);

----------------------------------------------------
--	Controller DDR3
----------------------------------------------------

label_ddr_stamp : ddr_stamp	
port map (

		
		--	global
				
		clk			=>	clk,
		reset		=>	reset,
				
		--	input	
		
		buffer_new_cmd_byte_addr_wr		=>	buffer_new_cmd_byte_addr_wr,
		buffer_new_cmd_byte_addr_rd		=>	buffer_new_cmd_byte_addr_rd,
		
		--	output

		Subtraction_addr_wr_addr_rd	=>	Subtraction_addr_wr_addr_rd	
		
       			
		);

ep23wire <= Subtraction_addr_wr_addr_rd	(31 downto 0);		

-- ----------------------------------------------------
-- manage ep20wire
-- ----------------------------------------------------

label_manage_ep20wire : manage_pipe_out	
port map (
		--	global
				
		clk			=>	clk,
		okClk		=>	okClk,		
		reset		=>	reset,			
		
		--	fifo interface
			
		rd_data_count	=>	rd_data_count,		
		
		--	ctrl interface
		
		ep20wire_three			=>	ep20wire_three
); 

-- ----------------------------------------------------
-- meta wire out
-- ----------------------------------------------------

process (okClk, reset) begin
if reset = '1' then

ep23wire_one <= (others => '0');
ep23wire_two <= (others => '0');
ep22wire_one <= (others => '0');
ep22wire_two <= (others => '0');
ep24wire_one <= (others => '0');
ep24wire_two <= (others => '0');
ep25wire_one <= (others => '0');
ep25wire_two <= (others => '0');
ep27wire_one <= (others => '0');
ep27wire_two <= (others => '0');
ep28wire_one <= (others => '0');
ep28wire_two <= (others => '0');

else
	if rising_edge (okClk) then

	
	ep23wire_one <= ep23wire; 
	ep23wire_two <= ep23wire_one; 	
	
	ep22wire_one <= ep22wire; 
	ep22wire_two <= ep22wire_one; 
	
	ep24wire_one <= ep24wire; 
	ep24wire_two <= ep24wire_one;
	
	ep25wire_one <= ep25wire;
	ep25wire_two <= ep25wire_one;


	
	ep27wire_one <= ep27wire;
	ep27wire_two <= ep27wire_one;
	
	ep28wire_one <= ep28wire;
	ep28wire_two <= ep28wire_one;
	
	end if;
end if;
end process;	

----------------------------------------------------
--	ok wire host
----------------------------------------------------

label_okHost : okHost	
port map(

	okUH	=>	okUH,
	okHU	=>	okHU,
	okUHU	=>	okUHU,
	okAA	=>	okAA,	--//temp removed for SIMULATION replace Core
	okClk	=>	okClk,	--out
	okHE	=>	okHE, 
	okEH	=>	okEH

); 

----------------------------------------------------
--	ok wire OR
----------------------------------------------------

label_okWireOR : okWireOR     generic map ( N => 11 ) 
port map (
	okEH	=>	okEH, 
	okEHx	=>	okEHx
);

----------------------------------------------------
--	ok wire in
----------------------------------------------------

label_okWireIn : okWireIn    
port map (
	okHE		=>	okHE,                                     
	ep_addr		=>	x"00", 
	ep_dataout	=>	ep00wire
);

----------------------------------------------------
--	ok wire out
----------------------------------------------------

label_okWireOut : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 1*65-1 downto 0*65 ), 
	ep_addr => x"24", 
	ep_datain => ep24wire_two 
	);	

----------------------------------------------------
--	ok pipe out
----------------------------------------------------

label_okPipeOut : okPipeOut--okBTPipeOut 
port map (
	okHE	=>	okHE, 
	okEH	=>	okEHx( 2*65-1 downto 1*65 ),  
	ep_addr	=>	x"A0", 
    ep_read	=>	po0_ep_read, 
	ep_datain		=>	po0_ep_datain 
	);		
	
	
----------------------------------------------------
--	ok wire out full flag
----------------------------------------------------

label_okWireOut_full : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 3*65-1 downto 2*65 ), 
	ep_addr => x"22", 
	ep_datain => ep22wire_two 
	);	

----------------------------------------------------
--	ok wire out ddr3 stamp lsb
----------------------------------------------------

label_okWireOut_ddr3_stamp_lsb : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 4*65-1 downto 3*65 ), 
	ep_addr => x"23", 
	ep_datain => ep23wire_two 
	);		
	
----------------------------------------------------
--	ok wire out ddr3 stamp msb
----------------------------------------------------

label_okWireOut_ddr3_stamp_msb : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 5*65-1 downto 4*65 ), 
	ep_addr => x"21", 
	ep_datain => ep20wire_three 
	);				

----------------------------------------------------
--	ok wire out ddr3 stamp msb
----------------------------------------------------

label_okWireOut_debug : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 6*65-1 downto 5*65 ), 
	ep_addr => x"25", 
	ep_datain => ep25wire_two 
	);		

----------------------------------------------------
--	ok wire out HK
----------------------------------------------------

label_okWireOut_hk : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 7*65-1 downto 6*65 ), 
	ep_addr => x"26", 
	ep_datain => ep26wire
	);	

----------------------------------------------------
--	ok wire debug
----------------------------------------------------

label_okWireOut_debug1 : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 8*65-1 downto 7*65 ), 
	ep_addr => x"27", 
	ep_datain => ep27wire_two 
	);	
		
----------------------------------------------------
--	ok wire debug
----------------------------------------------------

label_okWireOut_debug2 : okWireOut    
port map ( 
	okHE => okHE, 
	okEH => okEHx( 9*65-1 downto 8*65 ), 
	ep_addr => x"28", 
	ep_datain => ep28wire_two 
	);			

----------------------------------------------------
--	ok pipe out	hk
----------------------------------------------------

label_okPipeOut_hk : okPipeOut--okBTPipeOut 
port map (
	okHE	=>	okHE, 
	okEH	=>	okEHx( 10*65-1 downto 9*65 ),  
	ep_addr	=>	x"A1", 
    ep_read	=>	po0_ep_read_hk, 
	--ep_blockstrobe	=>	bs_out, 
	ep_datain		=>	po0_ep_datain_hk 
	--ep_ready		=>	pipe_out_ready
	);			

----------------------------------------------------
--	ok pipe in
----------------------------------------------------
	
label_okPipeIn : okPipeIn --okBTPipeIn  
port map (
	okHE	=>	okHE, 
	okEH	=>	okEHx( 11*65-1 downto 10*65 ),  
	ep_addr	=>	x"80", 
   ep_write=>	pi0_ep_write, 
	-- --ep_blockstrobe	=>	bs_in, 
	ep_dataout		=>	pi0_ep_dataout
	-- --ep_ready=>pipe_in_ready
	);	
	
	
process (clk, reset) begin
if reset = '1' then
ep22wire <= (others => '0'); 
enable_debug <= '0';
else

	if rising_edge (clk) then
	--	meta
	full_fifo_instrument_1 <= full_fifo_instrument;
	full_fifo_instrument_2 <= full_fifo_instrument_1;
	
	ep22wire(2) <= load_ep_wire;
	ep22wire(3) <= fifo_filled;
	ep22wire(4) <= empty;
	ep22wire(5) <= empty_fifo_instrument;
	ep22wire(6) <= enable_debug;
	
	--	detect error
		if pipe_out_full = '1' and full_fifo_instrument_2 = '0' and enable_debug = '1'  then
		ep22wire(0) <= '1';
		else
			if pipe_out_full = '0' and full_fifo_instrument_2 = '1' and enable_debug = '1' then
			ep22wire(1) <= '1';
			else
				if pipe_out_full = '1' and full_fifo_instrument_2 = '1' and enable_debug = '1' then
				ep22wire(1) <= '1';
				ep22wire(0) <= '1';
				end if;
			end if;
		end if;
		
		if load_ep_wire = '1' then	--	enable full flag after first gse read
		enable_debug <= '1';
		end if;
		
	end if;	
end if;
end process;		

---------------------------------------------------------------
--	instrument fifo
---------------------------------------------------------------
	
instrument_fifo_in	:	fifo_w32_131068_r128_32728 
port map (
	rst		=>	reset,
	wr_clk	=>	clk_science,
	rd_clk	=>	clk,
	din		=>	dataout_instrument,	--	pi0_ep_dataout	for test with pipe in (small packet)
	wr_en	=>	write_instrument,	--	pi0_ep_write	for test with pipe in (small packet)
	rd_en	=>	read_instrument,
	dout	=>	data_instrument, --// Bus [127 : 0] 
	full	=>	full_fifo_instrument,
	empty	=>	empty_fifo_instrument,
	valid	=>	valid_fifo_instrument,
	rd_data_count	=>	open, --// Bus [7 : 0] 
	wr_data_count	=>	open,	 --// Bus [9 : 0] 
    prog_empty 		=>	prog_empty
	
	
	); 

reset_n <= not reset;
	
-- ------------------------------------------------------------------------------------------------------
--   RX - Top level
-- ------------------------------------------------------------------------------------------------------
   label_science_data_rx: entity work.science_data_rx port map
   (     
   
   	reset_n 			=>	reset_n,
	i_clk_science 		=>	clk_science,
	
		
	-- Link
	
	i_science_ctrl		=>	i_science_ctrl,
	i_science_data		=>	i_science_data,
	data_rate_enable	=>	data_rate_enable,
	
	dataout_instrument		=>	dataout_instrument,
	dataout_instrument_wire	=>	dataout_instrument_wire,
	write_instrument 		=>	write_instrument	
   
   );   

data_rate_enable <= SYNC_OUT(2);   
     
---------------------------------------------------------------
-- simulate data rate by counter
---------------------------------------------------------------

process (okClk, reset) begin
if reset = '1' then
SYNC_OUT_one	<=	(others => '0'); 
SYNC_OUT_fast	<=	(others => '0'); 
else
	if rising_edge (okClk) then
	SYNC_OUT_one	<=	SYNC_OUT;	
	SYNC_OUT_fast	<=	SYNC_OUT_one;	
	start_stop_one <= ep00wire(2);
	start_stop_fast <= start_stop_one;  
	end if;
end if;
end process;	



---------------------------------------------------------------
--	Pipe out fifo 
---------------------------------------------------------------
	
okPipeOut_fifo	:	fifo_r32_131068_w128_32728   
port map (
	rst		=>	reset,
	wr_clk	=>	clk,
	rd_clk	=>	okClk,
	din		=>	pipe_out_data, --// Bus [127 : 0] 
	wr_en	=>	pipe_out_write,
	rd_en	=>	po0_ep_read,
	dout	=>	po0_ep_datain, --// Bus [31 : 0] 
	full	=>	open,
	empty	=>	empty,
	valid	=>	open,
	rd_data_count	=>	rd_data_count, --// Bus [9 : 0] 
	wr_data_count	=>	wr_data_count,--// Bus [7 : 0]
	prog_full	=>	pipe_out_full
	); 

ep27wire <= "00000000000000000"&wr_data_count; 
ep28wire <= "0000000000000000"&dataout_instrument_wire; 
		
---------------------------------------------------------------
--	Pipe out fifo  hk
---------------------------------------------------------------
	
okPipeOut_fifo_hk	:	fifo_r32_256_w32_256_hk   
port map (
	rst		=>	reset,
	wr_clk	=>	Clk,
	rd_clk	=>	okClk,
	din		=>	pipe_out_data_hk, --// Bus [127 : 0] 
	wr_en	=>	pipe_out_write_hk,
	rd_en	=>	po0_ep_read_hk,
	dout	=>	po0_ep_datain_hk, --// Bus [31 : 0] 
	full	=>	pipe_out_full_hk,
	empty	=>	empty_hk,
	rd_data_count	=>	rd_data_count_hk --// Bus [9 : 0] 
	);  

label_hk_pattern	:	hk_pattern   
port map (

		okClk	=>	okClk,			
		reset	=>	reset,		
		
		rd_data_count_hk	=>	rd_data_count_hk,	
	
		ep26wire			=>	ep26wire
	
	);  		
	
process (okClk, reset) begin
if reset = '1' then
ep25wire  				<= (others => '0');
signal_read_piper_out	<= (others => '0');
else
	if rising_edge (okClk) then
		if po0_ep_read = '1' then
		signal_read_piper_out <= signal_read_piper_out + 1;
		ep25wire	<= signal_read_piper_out;
		else
			if empty = '1' then
			ep25wire  <= (others => '0');
			signal_read_piper_out <= (others => '0');
			end if;
		end if;
	end if;
end if;
end process;		

---------------------------------------------------------------
--	Pipe in
---------------------------------------------------------------
	
okPipein_fifo	:	fifo_r32_256_w32_256   
port map (
	rst		=>	reset,
	wr_clk	=>	okClk,
	rd_clk	=>	Clk,
	din		=>	pi0_ep_dataout, --// Bus [127 : 0] 
	wr_en	=>	pi0_ep_write,
	rd_en	=>	pipe_in_read,
	dout	=>	pipe_in_data, --// Bus [31 : 0] 
	full	=>	open,
	empty	=>	pipe_in_empty,
	valid	=>	pipe_in_valid
	);  

---------------------------------------------------------------
--	read fifo in and write fifo out
---------------------------------------------------------------	
	
-- process (Clk, reset) begin
-- if reset = '1' then
-- pipe_in_read		<= '0';	
-- read_sended			<= '0';
-- pipe_out_write_hk	<= '0';
-- else
-- 	if rising_edge (Clk) then
-- 	pipe_in_read <= '0';
-- 	pipe_out_write_hk	<= '0';	
-- 		if	pipe_in_empty = '0' and pipe_in_read = '0' and read_sended = '0' and pipe_in_valid = '0' then
-- 		pipe_in_read <= '1';	
-- 		else
-- 			if pipe_in_valid = '1' and read_sended = '0' then
-- 			pipe_out_data_hk <= pipe_in_data; 	
-- 			read_sended		<= '1';
-- 			else
-- 				if	read_sended = '1' then
-- 				pipe_out_write_hk	<= '1';
-- 				read_sended			<= '0';
-- 				end if;
-- 			end if;
-- 		end if;
-- 	end if;
-- end if;
-- end process;			
	
	
end RTL;