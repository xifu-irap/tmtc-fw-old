--!   @file                   science_data_tx_ok.vhd from NanoXplore
--!   @details                Science data transmit

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_project_ok.all;

entity pattern is
	port(
		reset                	:	in		std_logic;                                                            
        clk_ng_large         	:	in		std_logic; 
		
		
		start_pattern			:	in		std_logic;
		ok_pattern				:	inout		t_sc_data_w(0 to c_DMX_NB_COL*c_SC_DATA_SER_NB);
		i_science_data_tx_ena	:	out		std_logic            
   );
end entity pattern;

architecture RTL of pattern is

--signal	ok_pattern					:	t_sc_data_w(0 to c_DMX_NB_COL*c_SC_DATA_SER_NB);
signal	ok_pattern_cpt				:	integer	range 0 to 8;	                          

signal	pattern_1			:	std_logic_vector(31 downto 0);
signal	pattern_2			:	std_logic_vector(31 downto 0);	

begin

-------------------------------------------------------------------------------------
--	label_pattern
-------------------------------------------------------------------------------------

label_pattern : process(reset, clk_ng_large)
begin
if reset = '1' then
ok_pattern 				<=	(others=> (others => '0'));
ok_pattern_cpt			<=	0;	
i_science_data_tx_ena	<=	'0';
else
    if clk_ng_large = '1' and clk_ng_large'event then
	ok_pattern(0) <= x"C0";
--	ok_pattern(1) <= x"AA";
--	ok_pattern(2) <= x"55";
	i_science_data_tx_ena	<=	'0';
	ok_pattern_cpt	<=	ok_pattern_cpt + 1;
		if ok_pattern_cpt = 7 and start_pattern = '1' then
		i_science_data_tx_ena	<=	'1';
		ok_pattern_cpt			<=	0;
		ok_pattern(1)			<=	pattern_1(7 downto 0);
		ok_pattern(2) 			<=	pattern_1(15 downto 8);
		ok_pattern(3)			<=	pattern_1(23 downto 16);
		ok_pattern(4) 			<=	pattern_1(31 downto 24);
		ok_pattern(5)			<=	pattern_2(7 downto 0);
		ok_pattern(6) 			<=	pattern_2(15 downto 8);
		ok_pattern(7)			<=	pattern_2(23 downto 16);
		ok_pattern(8) 			<=	pattern_2(31 downto 24);	
		else
			if ok_pattern_cpt = 5 and start_pattern = '1' then
			pattern_1	<=	std_logic_vector(unsigned(pattern_2) + 1);
			else
				if ok_pattern_cpt = 6 and start_pattern = '1' then
				pattern_2	<=	std_logic_vector(unsigned(pattern_1) + 1);	
				end if;
			end if;
		end if;	
	end if;
end if;  -- reset 
end process;

end architecture RTL;
