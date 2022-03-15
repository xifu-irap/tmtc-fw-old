-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                            Copyright (C) 2021-2030 Paul Marbeau, IRAP Toulouse.
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                            This file is part of the ATHENA X-IFU DRE Time Domain Multiplexing Firmware.
--
--                            ras_a75_fw is free software: you can redistribute it and/or modify
--                            it under the terms of the GNU General Public License as published by
--                            the Free Software Foundation, either version 3 of the License, or
--                            (at your option) any later version.
--
--                            This program is distributed in the hope that it will be useful,
--                            but WITHOUT ANY WARRANTY; without even the implied warranty of
--                            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--                            GNU General Public License for more details.
--
--                            You should have received a copy of the GNU General Public License
--                            along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    email                   paul.marbeau@alten.com
--!   @file                   slow_dac_spi_mgt.vhd
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--!   @details                Specific project constants
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_func_math.all;
use     work.pkg_project.all;

entity spi_mgt is port
   (     i_rst                : in     std_logic                                         ; --! Reset asynchronous assertion, synchronous de-assertion ('0' = Inactive, '1' = Active)
         i_clk                : in     std_logic                                         ; --! System Clock
         i_spi_data_tx        : in     std_logic_vector(c_DAC_SPI_SER_WD_S-1 downto 0)   ; --! Data to transmit
         i_miso               : in     std_logic                                         ; --! Serial data Master in Slave Out
         i_fifo_empty         : in     std_logic                                         ; --! Fifo State (Empty = '1', not Empty ='0') 

         o_read_en                : out    std_logic;                                      --! Read Fifo next value                    
         o_data_ready             : out    std_logic;
         o_data                   : out    std_logic_vector(c_DAC_SPI_SER_WD_S-1 downto 0)                                                                 ; 
         o_mosi                   : out    std_logic;   --! DAC - Serial Data
         o_sclk                   : out    std_logic;   --! Serial Clock
         o_sync_n                 : out    std_logic    --! Frame Synchronization ('0' = Active, '1' = Inactive)
   );
end entity spi_mgt;

architecture RTL of spi_mgt is
constant c_SPI_SER_WD_S_V_S   : integer := log2_ceil(c_DAC_SPI_SER_WD_S+1)                                  ; --! DAC SPI: Serial word size vector bus size
constant c_DAC_SPI_SER_WD_S_V : std_logic_vector(c_SPI_SER_WD_S_V_S-1 downto 0) :=
                                std_logic_vector(to_unsigned(c_DAC_SPI_SER_WD_S, c_SPI_SER_WD_S_V_S))       ; --! DAC SPI: Serial word size vector

signal spi_start     : std_logic; -- Starts SPI link (Active = '1', Inactive ='0')
signal spi_tx_busy_n : std_logic; -- SPI link state (Not Busy = '1', Busy = '0')
signal i_miso_r      : std_logic; -- Used to synchronize  i_miso
signal i_miso_r2     : std_logic; -- Used to synchronize  i_miso
signal read_en       : std_logic_vector(c_SPI_PAUSE-2 downto 0); -- Used to create the delay between two communications.

begin

   -- ------------------------------------------------------------------------------------------------------
   --!   SPI master
   --    @Req : 
   -- ------------------------------------------------------------------------------------------------------
   I_dac_spi_master : entity work.spi_master generic map
   (     g_CPOL               => c_DAC_SPI_CPOL       , -- std_logic                                        ; --! Clock polarity
         g_CPHA               => c_DAC_SPI_CPHA       , -- std_logic                                        ; --! Clock phase
         g_N_CLK_PER_SCLK_L   => c_DAC_SPI_SCLK_L     , -- integer                                          ; --! Number of clock period for elaborating SPI Serial Clock low  level
         g_N_CLK_PER_SCLK_H   => c_DAC_SPI_SCLK_H     , -- integer                                          ; --! Number of clock period for elaborating SPI Serial Clock high level
         g_N_CLK_PER_MISO_DEL => 2                    , -- integer                                          ; --! Number of clock period for miso signal delay from spi pin input to spi master input
         g_DATA_S             => c_DAC_SPI_SER_WD_S     -- integer                                            --! Data bus size
   ) port map
   (     i_rst                => i_rst                , -- in     std_logic                                 ; --! Reset asynchronous assertion, synchronous de-assertion ('0' = Inactive, '1' = Active)
         i_clk                => i_clk                , -- in     std_logic                                 ; --! Clock

         i_start              => spi_start        ,     -- in     std_logic                                 ; --! Start transmit ('0' = Inactive, '1' = Active)
         i_ser_wd_s           => c_DAC_SPI_SER_WD_S_V , -- in     slv(log2_ceil(g_DATA_S+1)-1 downto 0)     ; --! Serial word size
         i_data_tx            => i_spi_data_tx      ,   -- in     std_logic_vector(g_DATA_S-1 downto 0)     ; --! Data to transmit (stall on MSB)
         o_tx_busy_n          => spi_tx_busy_n    ,     -- out    std_logic                                 ; --! Transmit link busy ('0' = Busy, '1' = Not Busy)

         o_data_rx            => o_data                 , -- out    std_logic_vector(g_DATA_S-1 downto 0)     ; --! Receipted data (stall on LSB)
         o_data_rx_rdy        => o_data_ready           , -- out    std_logic                                 ; --! Receipted data ready ('0' = Not ready, '1' = Ready)

         i_miso               => i_miso_r2             , -- in     std_logic                                 ; --! SPI Master Input Slave Output
         o_mosi               => o_mosi       , -- out    std_logic                                 ; --! SPI Master Output Slave Input
         o_sclk               => o_sclk       , -- out    std_logic                                 ; --! SPI Serial Clock
         o_cs_n               => o_sync_n       -- out    std_logic                                   --! SPI Chip Select ('0' = Active, '1' = Inactive)
   );


  process (i_clk, i_rst)
  begin
      if i_rst = '1'                      -- Initialisation 
      then 
            read_en <= (others => '0') ;  
            spi_start <= '0' ;
            i_miso_r  <= '0' ;
            i_miso_r2 <= '0' ;
      elsif rising_edge(i_clk)
      then
            if spi_tx_busy_n = '1' and read_en = (read_en'range =>'0')  and i_fifo_empty = '0' -- Read one value with the appropriate delay
            then        
                  read_en <= read_en(read_en'high -1 downto 0) &  '1';  
            else
                  read_en <= read_en(read_en'high -1 downto 0) & '0' ;
            end if ;     
            spi_start <= read_en(read_en'high-1) ;                                            -- Start SPI communication
            i_miso_r2 <= i_miso_r ;                                                           -- Synchronize  i_miso
            i_miso_r  <= i_miso;

      end if ;
end process ; 
            o_read_en <= read_en(read_en'high-1) ;                                            -- Buffer 
end architecture RTL;
