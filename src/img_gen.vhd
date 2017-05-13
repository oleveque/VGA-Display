library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity img_gen is
   port(
      clock         : in std_logic;

      line_data     : in std_logic_vector(10 downto 0);
      column_data   : in std_logic_vector(10 downto 0);

      frst_pixel_h  : in std_logic_vector(10 downto 0);
      frst_pixel_v  : in std_logic_vector(10 downto 0);

      data          : out std_logic_vector(23 downto 0)
		);
end img_gen;

architecture Behavioral of img_gen is

signal tx: std_logic_vector(23 downto 0);

begin
   -- addr register to infer block RAM
   process (clock)
   begin
      if (rising_edge(clock)) then
         if (unsigned(column_data) <= X"50") then
            tx <= X"FFFFFF";

         elsif (X"50" < unsigned(column_data) and unsigned(column_data) <= X"A0") then
            tx <= X"FF0000";

         elsif (X"A0" < unsigned(column_data) and unsigned(column_data) <= X"F0") then
            tx <= X"FF8000";
         
			elsif (X"F0" < unsigned(column_data) and unsigned(column_data) <= X"140") then
            tx <= X"FFFF00";

         elsif (X"140" < unsigned(column_data) and unsigned(column_data) <= X"190") then
            tx <= X"00FF00";
				
         elsif (X"190" < unsigned(column_data) and unsigned(column_data) <= X"1E0") then
            tx <= X"0080FF"; 
			
			elsif (X"1E0" < unsigned(column_data) and unsigned(column_data) <= X"230") then
            tx <= X"FF00FF";

         elsif (X"230" < unsigned(column_data) and unsigned(column_data) <= X"280") then
            tx <= X"FF007F";
				
         else
            tx <= (others=>'0');

         end if;
      end if;
   end process;

   data <= tx;
end Behavioral;