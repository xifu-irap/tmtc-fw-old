
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package science_data_rx_package is

constant LinkNumber :   integer := 2;
constant ColNumber	:	integer	:= LinkNumber*2;
constant LignNumber	:	integer	:= ColNumber*2;


type t_ARRAY16bits is array (natural range <>) of std_logic_vector(15 downto 0);
type t_ARRAY8bits is array (LignNumber-1 downto 0) of std_logic_vector(7 downto 0);
type t_ARRAY3bits is array (LignNumber-1 downto 0) of std_logic_vector(2 downto 0);
type t_ARRAY8bits_ctrl is array ((ColNumber/2)-1 downto 0) of std_logic_vector(7 downto 0);
end science_data_rx_package;