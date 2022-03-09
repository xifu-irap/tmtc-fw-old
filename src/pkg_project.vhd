-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                            Copyright (C) 2021-2030 Paul MARBEAU, IRAP Toulouse.
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
--!   @file                   pkg_project.vhd
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--!   @details                Specific project constants
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package pkg_project is

constant c_DAC_SPI_CPOL       : std_logic := '0'                                                            ; --! DAC SPI: Clock polarity
constant c_DAC_SPI_CPHA       : std_logic := '0'                                                            ; --! DAC SPI: Clock phase
constant c_DAC_SPI_SER_WD_S   : integer   := 32                                                             ; --! DAC SPI: Data bus size
constant c_DAC_SPI_SCLK_L     : integer   := 8                                                               ; --! DAC SPI: Number of clock period for elaborating SPI Serial Clock low level
constant c_DAC_SPI_SCLK_H     : integer   := 8                                                              ; --! DAC SPI: Number of clock period for elaborating SPI Serial Clock high level

end pkg_project;
