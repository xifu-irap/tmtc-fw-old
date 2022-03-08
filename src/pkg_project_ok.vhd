--!   @file                   pkg_project_ok.vhd from NanoXplore
--!   @details                Specific project constants

library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_func_math.all;


package pkg_project_ok is

   -- ------------------------------------------------------------------------------------------------------
   --    System parameters
   -- ------------------------------------------------------------------------------------------------------
constant c_SWITCH_NB          : integer   := 5                                                              ; --! Switch number
constant c_FF_RESET_NB        : integer   := 2                                                              ; --! Flip-Flop number used for internal reset (TBC)
constant c_FF_RSYNC_NB        : integer   := 2                                                              ; --! Flip-Flop number used for FPGA input resynchronization

constant c_CLK_REF_MULT       : integer   := 5                                                              ; --! Reference Clock multiplier frequency factor (TBC)
constant c_CLK_MULT           : integer   := 12                                                             ; --! System Clock multiplier frequency factor (TBC)
constant c_CLK_ADC_MULT       : integer   := 6                                                              ; --! ADC Clock multiplier frequency factor (TBC)
constant c_CLK_DAC_MULT       : integer   := 6                                                              ; --! DAC Clock multiplier frequency factor (TBC)

   -- ------------------------------------------------------------------------------------------------------
   --  c_PLL_MAIN_VCO_MULT conditions to respect:
   --    - NG-LARGE:
   --       * Must be a common multiplier with c_CLK_REF_MULT and c_CLK_MULT
   --       * Vco frequency range : 200 MHz <= c_PLL_MAIN_VCO_MULT * c_CLK_COM_FREQ    <= 800 MHz
   --       * WFG pattern size    :            c_PLL_MAIN_VCO_MULT/c_CLK_REF_MULT      <= 16
   -- ------------------------------------------------------------------------------------------------------
constant c_PLL_MAIN_VCO_MULT  : integer   := 120                                                            ; --! PLL main VCO multiplier frequency factor (TBC)

constant c_CLK_COM_FREQ       : integer   := 5000000                                                        ; --! Clock frequency common to main clocks (Hz) (TBC)
constant c_CLK_REF_FREQ       : integer   := c_CLK_REF_MULT      * c_CLK_COM_FREQ                           ; --! Reference Clock frequency (Hz)
constant c_CLK_FREQ           : integer   := c_CLK_MULT          * c_CLK_COM_FREQ                           ; --! System Clock frequency (Hz)
constant c_CLK_ADC_FREQ       : integer   := c_CLK_ADC_MULT      * c_CLK_COM_FREQ                           ; --! ADC Clock frequency (Hz)
constant c_CLK_DAC_FREQ       : integer   := c_CLK_DAC_MULT      * c_CLK_COM_FREQ                           ; --! DAC Clock frequency (Hz)
constant c_PLL_MAIN_VCO_FREQ  : integer   := c_PLL_MAIN_VCO_MULT * c_CLK_COM_FREQ                           ; --! PLL main VCO frequency (Hz)

   -- ------------------------------------------------------------------------------------------------------
   --    Interface parameters
   -- ------------------------------------------------------------------------------------------------------
constant c_SQ1_ADC_DATA_S     : integer   := 14                                                             ; --! SQUID1 ADC data size bus
constant c_SQ1_DAC_DATA_S     : integer   := 14                                                             ; --! SQUID1 DAC data size bus
constant c_SC_DATA_SER_W_S    : integer   := 8                                                              ; --! Science data serial word size
constant c_SC_DATA_SER_NB     : integer   := 2                                                              ; --! Science data serial link number by DEMUX column

   -- ------------------------------------------------------------------------------------------------------
   --    Inputs default value at reset
   -- ------------------------------------------------------------------------------------------------------
constant c_I_SPI_DATA_DEF     : std_logic := '0'                                                            ; --! SPI data input default value at reset
constant c_I_SPI_SCLK_DEF     : std_logic := '0'                                                            ; --! SPI Serial Clock input default value at reset
constant c_I_SPI_CS_N_DEF     : std_logic := '1'                                                            ; --! SPI Chip Select input default value at reset
constant c_I_SQ1_ADC_DATA_DEF : std_logic_vector(c_SQ1_ADC_DATA_S-1 downto 0):= (others =>'0')              ; --! SQUID1 ADC data input default value at reset
constant c_I_SQ1_ADC_OOR_DEF  : std_logic := '0'                                                            ; --! SQUID1 ADC out of range input default value at reset
constant c_I_SYNC_DEF         : std_logic := '0'                                                            ; --! Pixel sequence synchronization default value at reset

   -- ------------------------------------------------------------------------------------------------------
   --    Project parameters
   -- ------------------------------------------------------------------------------------------------------
constant c_DMX_MUX_FACT       : integer   := 34                                                             ; --! DEMUX: multiplexing factor
constant c_DMX_NB_COL         : integer   := 4                                                              ; --! DEMUX: column number
constant c_DRE_PIX_NPER_COM   : integer   := 4                                                              ; --! DRE: period number of clock common to main clocks allocated to one sequence pixel (TBC)

   -- ------------------------------------------------------------------------------------------------------
   --    SQUID1 ADC parameters
   -- ------------------------------------------------------------------------------------------------------
constant c_ADC_DATA_NPER      : integer   := 13                                                             ; --! Clock period number between the acquisition start and data output by the ADC
constant c_ADC_DATA_IO_NPER   : integer   := 1                                                              ; --! Clock period number applied on FPGA inputs for phasing ADC data with o_clk_sq1_adc

constant c_PIX_SEQ_NPER_ADC   : integer   := c_CLK_ADC_MULT * c_DRE_PIX_NPER_COM                            ; --! Period number of ADC clock allocated to one sequence pixel

   -- ------------------------------------------------------------------------------------------------------
   --    Global types
   -- ------------------------------------------------------------------------------------------------------
type     t_sq1_adc_data_v      is array (natural range <>) of std_logic_vector(c_SQ1_ADC_DATA_S-1  downto 0); --! SQUID1 ADC data vector type
type     t_sc_data_w           is array (natural range <>) of std_logic_vector(c_SC_DATA_SER_W_S-1 downto 0); --! Science data word

end pkg_project_ok;
