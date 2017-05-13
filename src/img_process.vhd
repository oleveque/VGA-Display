library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity img_process is
   port(
   		--port for img_ROM
   		clk		  	  : in  std_logic;
   		v_count		  : in std_logic_vector(10 downto 0);
   		h_count		  : in std_logic_vector(10 downto 0);
   		TopLeftPixel_h: in std_logic_vector(10 downto 0);
   		TopLeftPixel_v: in std_logic_vector(10 downto 0);

   		--port for img_process
   		slct_img		  : in  std_logic_vector(1 downto 0);
   		slct_Prc_img	  : in  std_logic_vector(1 downto 0);
		data_out	 	  : out std_logic_vector(23 downto 0)
	);
end img_process;

architecture Behavioral of img_process is

	component img_rom is
	port(
		clock 			: in std_logic;

      	line_data		: in std_logic_vector(10 downto 0);
      	column_data		: in std_logic_vector(10 downto 0);

      	frst_pixel_h 	: in std_logic_vector(10 downto 0);
      	frst_pixel_v 	: in std_logic_vector(10 downto 0);

      	data 			: out std_logic_vector(23 downto 0)
	);
	end component;

	component img_gen is
	port(
		clock 			: in std_logic;

      	line_data		: in std_logic_vector(10 downto 0);
      	column_data		: in std_logic_vector(10 downto 0);

      	frst_pixel_h 	: in std_logic_vector(10 downto 0);
      	frst_pixel_v 	: in std_logic_vector(10 downto 0);

      	data 			: out std_logic_vector(23 downto 0)
	);
	end component;

	signal red 		: unsigned(7 downto 0);
	signal green 	: unsigned(7 downto 0);
	signal blue 	: unsigned(7 downto 0);

	signal data_rom	: std_logic_vector(23 downto 0);
	signal data_flag: std_logic_vector(23 downto 0);

	signal gray 	: unsigned(7 downto 0);


begin
	i1 : img_rom port map (
		clock => clk,

      	line_data => v_count,
      	column_data => h_count,

      	frst_pixel_h => TopLeftPixel_h,
      	frst_pixel_v => TopLeftPixel_v,

      	data => data_rom
	);

	i2 : img_gen port map (
		clock => clk,

      	line_data => v_count,
      	column_data => h_count,

      	frst_pixel_h => TopLeftPixel_h,
      	frst_pixel_v => TopLeftPixel_v,

      	data => data_flag
	);
	
	process (data_rom, data_flag, red, green, blue, slct_img, slct_Prc_img,clk)
   begin
		if (rising_edge(clk)) then
   		if (slct_img = "00") then
				red <= unsigned(data_flag(23 downto 16));
				green <= unsigned(data_flag(15 downto 8));
				blue <= unsigned(data_flag(7 downto 0));
				gray <= (unsigned(data_flag(23 downto 16)) srl 2)+(unsigned(data_flag(23 downto 16)) srl 5)+(unsigned(data_flag(23 downto 16)) srl 6)+
							(unsigned(data_flag(15 downto 8)) srl 1)+(unsigned(data_flag(15 downto 8)) srl 4)+(unsigned(data_flag(15 downto 8)) srl 5)+(unsigned(data_flag(15 downto 8)) srl 6)+(unsigned(data_flag(15 downto 8)) srl 7)+
							(unsigned(data_flag(7 downto 0)) srl 4)+(unsigned(data_flag(7 downto 0)) srl 5)+(unsigned(data_flag(7 downto 0)) srl 6)+(unsigned(data_flag(7 downto 0)) srl 7);
	

			elsif (slct_img = "01") then
				red <= unsigned(data_rom(23 downto 16));
				green <= unsigned(data_rom(15 downto 8));
				blue <= unsigned(data_rom(7 downto 0));
				
				gray <= (unsigned(data_rom(23 downto 16)) srl 2)+(unsigned(data_rom(23 downto 16)) srl 5)+(unsigned(data_rom(23 downto 16)) srl 6)+
							(unsigned(data_rom(15 downto 8)) srl 1)+(unsigned(data_rom(15 downto 8)) srl 4)+(unsigned(data_rom(15 downto 8)) srl 5)+(unsigned(data_rom(15 downto 8)) srl 6)+(unsigned(data_rom(15 downto 8)) srl 7)+
							(unsigned(data_rom(7 downto 0)) srl 4)+(unsigned(data_rom(7 downto 0)) srl 5)+(unsigned(data_rom(7 downto 0)) srl 6)+(unsigned(data_rom(7 downto 0)) srl 7);
	

			end if;

			if (slct_Prc_img = "00") then
				data_out(23 downto 16) <= std_logic_vector(red); 
				data_out(15 downto 8) <= std_logic_vector(green); 
				data_out(7 downto 0) <= std_logic_vector(blue);
			
			elsif (slct_Prc_img = "01") then
				data_out(23 downto 16) <= std_logic_vector(gray); 
				data_out(15 downto 8) <= std_logic_vector(gray); 
				data_out(7 downto 0) <= std_logic_vector(gray);
				
			elsif (slct_Prc_img = "10") then
				if (gray > 235) then
					data_out <= (others => '1');
					
				else
					data_out <= (others => '0');
				
				end if;
			
			elsif (slct_Prc_img = "11") then
				
				data_out(23 downto 16) <= std_logic_vector(255-red); 
				data_out(15 downto 8) <= std_logic_vector(255-green); 
				data_out(7 downto 0) <= std_logic_vector(255-blue);
					
			end if;		
		end if;
	end process;
end Behavioral;