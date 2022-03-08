
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

package science_data_rx_package is


constant ColNumber	:	integer	:= 4;
constant LinkNumber	:	integer	:= ColNumber*2;


type t_ARRAY16bits is array (natural range <>) of std_logic_vector(15 downto 0);
type t_ARRAY8bits is array (LinkNumber-1 downto 0) of std_logic_vector(7 downto 0);
type t_ARRAY3bits is array (LinkNumber-1 downto 0) of std_logic_vector(2 downto 0);

end science_data_rx_package;