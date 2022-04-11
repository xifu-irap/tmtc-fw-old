----------------------------------------------------------------------------------
-- Company  : IRAP CNRS 
-- Engineer : Bernard Bertrand
-- 
-- Create Date:    17:00:51 07/31/2015 
-- Design Name:    Ramtester
-- Module Name:    Ramtest - RTL 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use ieee.float_pkg.all;
--use std.textio.all;

---------------------------------------------------------------
--
-- PACKAGE
--
---------------------------------------------------------------
package Ramtest_pack is

 
constant BANK_WIDTH            :	integer	:= 3;                                   -- --// # of memory Bank Address bits.
constant CK_WIDTH              :	integer	:= 1;                                  
constant CS_WIDTH              :	integer	:= 1;
constant nCS_PER_RANK          :	integer	:= 1;
constant CKE_WIDTH             :	integer	:= 1;
constant DM_WIDTH              :	integer	:= 2;
constant DQ_WIDTH              :	integer	:= 16;
constant DQS_WIDTH             :	integer	:= 2;
constant ODT_WIDTH             :	integer	:= 1;
constant ROW_WIDTH             :	integer	:= 15;
constant ADDR_WIDTH            :	integer	:= 29;
constant nCK_PER_CLK           :	integer	:= 4;
constant PAYLOAD_WIDTH         :	integer	:= 16;  
constant APP_DATA_WIDTH        :	integer	:= 128; 								 
constant APP_MASK_WIDTH        :	integer	:= 16;

--OK RamTest Parameters
constant BLOCK_SIZE	:	integer	:= 128; 
constant FIFO_SIZE	:	integer	:= 1024;

component	fifo_r32_256_w32_256_hk
		port(
		rst		: 	in	STD_LOGIC;
		wr_clk	: 	in	STD_LOGIC;
		rd_clk	: 	in	STD_LOGIC;
		din		: 	IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en	: 	in	STD_LOGIC;
		rd_en	: 	in	STD_LOGIC;
		dout	: 	out STD_LOGIC_VECTOR(31 DOWNTO 0);
		full	: 	out	STD_LOGIC;
		empty	: 	out	STD_LOGIC;
		rd_data_count	: 	IN STD_LOGIC_VECTOR(9 DOWNTO 0)		

		);
end component;			
		
component	fifo_r32_256_w32_256   
		port(
		rst		: 	in	STD_LOGIC;
		wr_clk	: 	in	STD_LOGIC;
		rd_clk	: 	in	STD_LOGIC;
		din		: 	IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en	: 	in	STD_LOGIC;
		rd_en	: 	in	STD_LOGIC;
		dout	: 	out STD_LOGIC_VECTOR(31 DOWNTO 0);
		full	: 	out	STD_LOGIC;
		empty	: 	out	STD_LOGIC;
		valid	: 	out	STD_LOGIC
--		data_count	: 	IN STD_LOGIC_VECTOR(9 DOWNTO 0)

		);
end component;		

component hk_pattern

		port(
		okClk		: 	in	STD_LOGIC;
		reset		: 	in	STD_LOGIC;
		
		rd_data_count_hk	:	in	std_logic_vector(9 downto 0);

		ep26wire			: 	out	std_logic_vector(31 downto 0)
		
		);
end component;		
	
component manage_pipe_out
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
end component;			

-- component manage_threshold
		-- port(
		
		-- --	global
				
		-- clk			: 	in	STD_LOGIC;
		-- reset		: 	in	STD_LOGIC;		
		
		-- --	input
		
		-- prog_empty	: 	in	STD_LOGIC;
		-- prog_full	: 	in	STD_LOGIC;
		
		-- --	output
			
		-- before_prog_full	: 	out	STD_LOGIC;
		-- before_prog_empty	: 	out	STD_LOGIC		
		
		-- );
-- end component;	

component ddr_stamp 
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
end component;	

									 
component fifo_w32_131068_r128_32728 port (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
--	prog_full 		: OUT STD_LOGIC;
    prog_empty 		: OUT STD_LOGIC
	
	
	 );
	end component;	
	
component fifo_r32_131068_w128_32728 port (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
	prog_full: OUT STD_LOGIC
	  );
	end component;										 

component fifo_w32_1024_r128_256 port (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	  );
	end component;		

component fifo_w32_256_r32_256  port (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	end component;			
	
component ddr3_256_16 
generic (
	-- --***************************************************************************
   -- -- The following parameters refer to width of various ports
   -- --***************************************************************************
PAYLOAD_WIDTH         : integer := 16; 
BANK_WIDTH            : integer := 3;
DQ_WIDTH              : integer := 16;    
DQS_WIDTH             : integer := 2;                              
ROW_WIDTH             : integer := 15;									 
CK_WIDTH              : integer := 1;
CKE_WIDTH             : integer := 1;
CS_WIDTH              : integer := 1;
DM_WIDTH              : integer := 2;
nCS_PER_RANK          : integer := 1;
ODT_WIDTH             : integer := 1;
ADDR_WIDTH            : integer := 29;
nCK_PER_CLK           : integer := 4
 
	
	); 
port (
--// Memory interface ports
   -- Inouts
   ddr3_dq                        : inout std_logic_vector(DQ_WIDTH-1 downto 0);
   ddr3_dqs_p                     : inout std_logic_vector(DQS_WIDTH-1 downto 0);
   ddr3_dqs_n                     : inout std_logic_vector(DQS_WIDTH-1 downto 0);

   -- Outputs
   ddr3_addr                      : out   std_logic_vector(ROW_WIDTH-1 downto 0);
   ddr3_ba                        : out   std_logic_vector(BANK_WIDTH-1 downto 0);
   ddr3_ras_n                     : out   std_logic;
   ddr3_cas_n                     : out   std_logic;
   ddr3_we_n                      : out   std_logic;
   ddr3_reset_n                   : out   std_logic;
   ddr3_ck_p                      : out   std_logic_vector(CK_WIDTH-1 downto 0);
   ddr3_ck_n                      : out   std_logic_vector(CK_WIDTH-1 downto 0);
   ddr3_cke                       : out   std_logic_vector(CKE_WIDTH-1 downto 0);
   ddr3_cs_n                      : out   std_logic_vector(CS_WIDTH*nCS_PER_RANK-1 downto 0);
   ddr3_dm                        : out   std_logic_vector(DM_WIDTH-1 downto 0);
   ddr3_odt                       : out   std_logic_vector(ODT_WIDTH-1 downto 0);

   -- Inputs
   -- Differential system clocks
   sys_clk_p                      : in    std_logic;
   sys_clk_n                      : in    std_logic;
   -- Single-ended iodelayctrl clk (reference clock)
--   clk_ref_i                                : in    std_logic;
   -- user interface signals
   app_addr             : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
   app_cmd              : in    std_logic_vector(2 downto 0);
   app_en               : in    std_logic;
   app_wdf_data         : in    std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
   app_wdf_end          : in    std_logic;
   app_wdf_mask         : in    std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)/8-1 downto 0)  ;
   app_wdf_wren         : in    std_logic;
   app_rd_data          : out   std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
   app_rd_data_end      : out   std_logic;
   app_rd_data_valid    : out   std_logic;
   app_rdy              : out   std_logic;
   app_wdf_rdy          : out   std_logic;
   app_sr_req           : in    std_logic;
   app_sr_active        : out   std_logic;
   app_ref_req          : in    std_logic;
   app_ref_ack          : out   std_logic;
   app_zq_req           : in    std_logic;
   app_zq_ack           : out   std_logic;
   ui_clk               : out   std_logic;
   ui_clk_sync_rst      : out   std_logic;
   
      
   
   init_calib_complete  : out std_logic;
   
      

   -- System reset - Default polarity of sys_rst pin is Active Low.
   -- System reset polarity will change based on the option 
   -- selected in GUI.
    sys_rst                     : in    std_logic
);
end component;		
	
component drive_interface_ddr3_ctrl 
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

end component;		

component start_stop 
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

end component;	


   -- =============================================================
    function endian64(rhs : std_logic_vector(63 downto 0)) return std_logic_vector;
    function endian32(rhs : std_logic_vector(31 downto 0)) return std_logic_vector;
--    function binstr_to_stdvec(inp: string; nbbit : integer) return std_logic_vector;	


end Ramtest_pack;

package body Ramtest_pack is
    -- =============================================================
    -- =============================================================
    function endian64(rhs : std_logic_vector(63 downto 0)) return std_logic_vector is
        variable x : std_logic_vector(63 downto 0);
   begin
        x(63 downto 56) := rhs(39 downto 32);
        x(55 downto 48) := rhs(47 downto 40);
        x(47 downto 40) := rhs(55 downto 48);
        x(39 downto 32) := rhs(63 downto 56);

        x(31 downto 24) := rhs(7 downto 0);
        x(23 downto 16) := rhs(15 downto 8);
        x(15 downto 8)  := rhs(23 downto 16);
        x(7 downto 0)   := rhs(31 downto 24);
        return x;
    end function endian64;
    -- =============================================================
    -- =============================================================
    function endian32(rhs : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable x : std_logic_vector(31 downto 0);
   begin
        x(31 downto 24) := rhs(7 downto 0);
        x(23 downto 16) := rhs(15 downto 8);
        x(15 downto 8)  := rhs(23 downto 16);
        x(7 downto 0)   := rhs(31 downto 24);
        return x;
    end function endian32; 	

end Ramtest_pack;