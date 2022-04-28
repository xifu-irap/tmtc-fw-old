--!   @file                   pkg_func_math.vhd	from NanoXplore
--!   @details                Mathematical function package

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

package pkg_func_math is

function log2_ceil              (X: in integer) return integer                                              ; --! return logarithm base 2 of X  (ceil integer)
function div_ceil               (X: in integer; Y : in integer) return integer                              ; --! returns X/Y (ceil integer)
function div_floor              (X: in integer; Y : in integer) return integer                              ; --! returns X/Y (floor integer)
function div_round              (X: in integer; Y : in integer) return integer                              ; --! returns X/Y (round integer)

end pkg_func_math;

package body pkg_func_math is

   -- ------------------------------------------------------------------------------------------------------
   --! return logarithm base 2 of X  (ceil integer)
   -- ------------------------------------------------------------------------------------------------------
   function log2_ceil           (X: in integer) return integer is
   begin
      return integer(ceil(log2(real(X))));
   end function;

   -- ------------------------------------------------------------------------------------------------------
   --! returns X/Y (ceil integer)
   -- ------------------------------------------------------------------------------------------------------
   function div_ceil            (X: in integer; Y : in integer) return integer is
   begin
       return integer(ceil(real(X)/real(Y)));
   end function;

   -- ------------------------------------------------------------------------------------------------------
   --! returns X/Y (floor integer)
   -- ------------------------------------------------------------------------------------------------------
   function div_floor           (X: in integer; Y : in integer) return integer is
   begin
       return integer(floor(real(X)/real(Y)));
   end function;

   -- ------------------------------------------------------------------------------------------------------
   --! returns X/Y (round integer)
   -- ------------------------------------------------------------------------------------------------------
   function div_round           (X: in integer; Y : in integer) return integer is
   begin
       return integer(round(real(X)/real(Y)));
   end function;

end pkg_func_math;
