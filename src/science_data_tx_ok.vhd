--!   @file                   science_data_tx_ok.vhd from NanoXplore
--!   @details                Science data transmit

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_func_math.all;
use     work.pkg_project_ok.all;


entity science_data_tx_ok is port
   (     i_rst                : in     std_logic                                                            ; --! Reset asynchronous assertion, synchronous de-assertion ('0' = Inactive, '1' = Active)
         i_clk                : in     std_logic                                                            ; --! System Clock

         i_science_data_tx_ena: in     std_logic                                                            ; --! Science Data transmit enable
         i_science_data       : in     t_sc_data_w(0 to c_DMX_NB_COL*c_SC_DATA_SER_NB)                      ; --! Science Data word
         o_science_data_ser   : out    std_logic_vector(c_DMX_NB_COL*c_SC_DATA_SER_NB downto 0)               --! Science Data – Serial Data
   );
end entity science_data_tx_ok;

architecture RTL of science_data_tx_ok is
constant SER_BIT_CNT_NB_VAL   : integer:= c_SC_DATA_SER_W_S                                                 ; --! Serial bit counter: number of value
constant SER_BIT_CNT_MAX_VAL  : integer:= SER_BIT_CNT_NB_VAL-2                                              ; --! Serial bit counter: maximal value
constant SER_BIT_CNT_S        : integer:= log2_ceil(SER_BIT_CNT_MAX_VAL+1)+1                                ; --! Serial bit counter: size bus (signed)

signal   ser_bit_cnt          : std_logic_vector(SER_BIT_CNT_S-1 downto 0)                                  ; --! Serial bit counter
signal   science_data_ser     : t_sc_data_w(0 to c_DMX_NB_COL*c_SC_DATA_SER_NB)                             ; --! Science Data – Serial Data

begin

   -- ------------------------------------------------------------------------------------------------------
   --!   Serial bit counter
   -- ------------------------------------------------------------------------------------------------------
   P_ser_bit_cnt : process (i_rst, i_clk)
   begin

      if i_rst = '1' then
         ser_bit_cnt <= (others => '1');

      elsif rising_edge(i_clk) then
         if (i_science_data_tx_ena and ser_bit_cnt(ser_bit_cnt'high)) = '1' then
            ser_bit_cnt <= std_logic_vector(to_signed(SER_BIT_CNT_MAX_VAL, ser_bit_cnt'length));

         elsif ser_bit_cnt(ser_bit_cnt'high) = '0' then
            ser_bit_cnt <= std_logic_vector(signed(ser_bit_cnt) - 1);

         end if;

      end if;

   end process P_ser_bit_cnt;

   -- ------------------------------------------------------------------------------------------------------
   --!   Science data serial
   -- ------------------------------------------------------------------------------------------------------
   G_science_data_ser: for k in 0 to o_science_data_ser'high generate
   begin

      P_science_data_ser : process (i_rst, i_clk)
      begin

         if i_rst = '1' then
            science_data_ser(k) <= (others => '0');

         elsif rising_edge(i_clk) then
            if (i_science_data_tx_ena and ser_bit_cnt(ser_bit_cnt'high)) = '1' then
               science_data_ser(k) <= i_science_data(k);

            else
               science_data_ser(k) <= science_data_ser(k)(c_SC_DATA_SER_W_S-2 downto 0) & '0';

            end if;

         end if;

      end process P_science_data_ser;

      o_science_data_ser(k) <= science_data_ser(k)(c_SC_DATA_SER_W_S-1);

   end generate G_science_data_ser;

end architecture rtl;
