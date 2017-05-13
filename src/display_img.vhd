library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_img is
	PORT(
		--Avalon interfaces signals
		reset  		: in std_logic;
		clk	   		: in std_logic;
		Address		: in std_logic_vector(2 downto 0);
		ChipSelect	: in std_logic;
		Read 		: in std_logic;
		Write		: in std_logic;
		ReadData 	: out std_logic_vector (31 downto 0);
		WriteData	: in std_logic_vector(31 downto 0);

		--VGA signals
		HS_VGA : out std_logic;
		VS_VGA : out std_logic;

		N_BLANK_DAC : out std_logic;
		N_SYNC_DAC	: out std_logic;

		G_DAC : out std_logic_vector(7 downto 0);
		R_DAC : out std_logic_vector(7 downto 0);
		B_DAC : out std_logic_vector(7 downto 0);
		
		switch1 : in std_logic;
		switch2 : in std_logic;
		switch3 : in std_logic;
		switch4 : in std_logic;
		switch5 : in std_logic
	);
end display_img;

architecture Behavioral of display_img is
	
	COMPONENT vga_controller_640_60 IS
	PORT(
		rst         : in std_logic;
	   	pixel_clk   : in std_logic;

	   	HS          : out std_logic;
	   	VS          : out std_logic;

	   	hcount      : out std_logic_vector(10 downto 0);
	   	vcount      : out std_logic_vector(10 downto 0);

	   	disp_ena    : out std_logic;

	   	n_blank   	: out std_logic;
	   	n_sync    	: out std_logic
	);
	END COMPONENT;
	
	COMPONENT img_process IS
	port(
		--port for img_ROM
   		clk		  	   : in  std_logic;
   		v_count		   : in std_logic_vector(10 downto 0);
   		h_count		   : in std_logic_vector(10 downto 0);
   		TopLeftPixel_h : in std_logic_vector(10 downto 0);
   		TopLeftPixel_v : in std_logic_vector(10 downto 0);

   		--port for img_process
   		slct_img		: in  std_logic_vector(1 downto 0);
   		slct_Prc_img 	: in  std_logic_vector(1 downto 0);
		data_out	  	: out std_logic_vector(23 downto 0)
	);
	END COMPONENT;

	signal iStart				: std_logic;
	signal iSelectImg 			: std_logic_vector(1 downto 0);
	signal iSelectImgProcess 	: std_logic_vector(1 downto 0);

	signal green :  std_logic_vector(7 downto 0);
	signal blue  :  std_logic_vector(7 downto 0);
	signal red   :  std_logic_vector(7 downto 0);

	signal display : std_logic;

	signal h_count_int : std_logic_vector(10 downto 0);
	signal v_count_int : std_logic_vector(10 downto 0);

	signal data_img : std_logic_vector(23 downto 0);


	begin
	i1 : vga_controller_640_60 port map ( 
		rst => reset, 
		pixel_clk => clk, 
		
		HS => HS_VGA, 
		VS => VS_VGA, 
		
		hcount => h_count_int, 
		vcount => v_count_int, 
		
		disp_ena => display,

		n_blank => N_BLANK_DAC,
	   	n_sync => N_SYNC_DAC
	);
	
	i2 : img_process port map (
		--port for img_ROM
   		clk		  	   => clk,
   		v_count		   => v_count_int,
   		h_count		   => h_count_int,
   		TopLeftPixel_h => "00010011011", --70 pixels
   		TopLeftPixel_v => "00010100000", --119 pixels

   		--port for img_process
   		slct_img		  => iSelectImg,
   		slct_Prc_img	  => iSelectImgProcess,
		data_out	      => data_img
	);
		

	R_DAC <= red;
	G_DAC <= green;
	B_DAC <= blue;
	
	
	
	--Avalon communications
	pRegWr	: process(clk,reset)
	begin
		if reset = '1' then -- asynchonous Reset
			iStart <= '0';
			iSelectImg <= "00";
			iSelectImgProcess <= "00";
		elsif rising_edge(Clk) then
			if ChipSelect = '1' and Write = '1' and switch5='1' then
				case Address (2 Downto 0) is
					when "000" => iStart <= WriteData(0);
					when "001" => iSelectImg <= WriteData(1 downto 0);
					when "010" => iSelectImgProcess <= WriteData(1 downto 0);
					when others => null;
				end case;
			elsif switch5='0' then
				iStart<=switch1;
				iSelectImg(0)<=switch2;
				iSelectImg(1)<='0';
				iSelectImgProcess(0)<=switch3;
				iSelectImgProcess(1)<=switch4;
			end if;
		end if;
	end process pRegWr;
	
	pRegRd: process(Clk)
	begin 
		if rising_edge(Clk) then
			ReadData <= (others => '0');
			if ChipSelect = '1' and Read = '1' then
				case Address(2 Downto 0) is
					when "000" => ReadData(0) <= iStart;
					when "001" => ReadData(1 downto 0) <= iSelectImg;
					when "010" => ReadData(1 downto 0) <= iSelectImgProcess;
					when others => null;
				end case ;
			end if;
		end if;
	end process pRegRd;

	--Display VGA interface
	affichage: process(h_count_int,v_count_int,display)
	begin
		if (display='1' or iStart='0') then
			blue <= (others => '0');
			green <= (others => '0');
			red <= (others => '0');

		else
			blue <= data_img(7 downto 0);
			green <= data_img(15 downto 8);
			red <= data_img(23 downto 16);
			
		end if;
	end process;

end Behavioral;

