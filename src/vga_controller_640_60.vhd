library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga_controller_640_60 is
port(
   rst         : in std_logic;          --active high asycnchronous reset
   pixel_clk   : in std_logic;          --pixel clock at frequency of VGA mode being used

   HS          : out std_logic;         --horiztonal sync pulse
   VS          : out std_logic;         --vertical sync pulse

   hcount      : out std_logic_vector(10 downto 0);   --horizontal pixel coordinate
   vcount      : out std_logic_vector(10 downto 0);   --vertical pixel coordinate

   disp_ena    : out std_logic;           --display enable ('1' = display time, '0' = blanking time)

   n_blank     :  out std_logic;          -- direct blacking output to DAC
   n_sync      :  out std_logic           -- sync-on-green output to DAC
);
end vga_controller_640_60;

architecture Behavioral of vga_controller_640_60 is

------------------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------------------

-- maximum value for the horizontal pixel counter
constant HMAX  : std_logic_vector(10 downto 0) := "01100100000"; -- 800

-- maximum value for the vertical pixel counter
constant VMAX  : std_logic_vector(10 downto 0) := "01000001101"; -- 525

-- total number of visible columns
constant HLINES: std_logic_vector(10 downto 0) := "01010000000"; -- 640

-- value for the horizontal counter where front porch ends
constant HFP   : std_logic_vector(10 downto 0) := "01010001000"; -- 648

-- value for the horizontal counter where the synch pulse ends
constant HSP   : std_logic_vector(10 downto 0) := "01011101000"; -- 744

-- total number of visible lines
constant VLINES: std_logic_vector(10 downto 0) := "00111100000"; -- 480

-- value for the vertical counter where the front porch ends
constant VFP   : std_logic_vector(10 downto 0) := "00111100010"; -- 482

-- value for the vertical counter where the synch pulse ends
constant VSP   : std_logic_vector(10 downto 0) := "00111100100"; -- 484

-- polarity of the horizontal and vertical synch pulse
-- only one polarity used, because for this resolution they coincide.
constant SPP   : std_logic := '0';

------------------------------------------------------------------------
-- SIGNALS
------------------------------------------------------------------------

-- horizontal and vertical counters
signal hcounter : std_logic_vector(10 downto 0) := (others => '0');
signal vcounter : std_logic_vector(10 downto 0) := (others => '0');

-- active when inside visible screen area.
signal video_enable: std_logic;

begin

   -- output horizontal and vertical counters
   hcount <= hcounter;
   vcount <= vcounter;

   -- disp_ena is active when outside screen visible area
   -- color output should be blacked (put on 0) when disp_ena in active
   -- disp_ena is delayed one pixel clock period from the video_enable
   -- signal to account for the pixel pipeline delay.
   disp_ena <= not video_enable when rising_edge(pixel_clk);

   -- enable video output when pixel is in visible area
   video_enable <= '1' when (hcounter < HLINES and vcounter < VLINES) else '0';

   --no direct blanking
   n_blank <= '1';
   --no sync on green
   n_sync <= '0';

   -- increment horizontal counter at pixel_clk rate
   -- until HMAX is reached, then reset and keep counting
   h_count: process(pixel_clk)
   begin
      if(rising_edge(pixel_clk)) then
         if(rst = '1') then
            hcounter <= (others => '0');
         elsif(hcounter = HMAX) then
            hcounter <= (others => '0');
         else
            hcounter <= std_logic_vector(unsigned(hcounter) + 1);
         end if;
      end if;
   end process h_count;

   -- increment vertical counter when one line is finished
   -- (horizontal counter reached HMAX)
   -- until VMAX is reached, then reset and keep counting
   v_count: process(pixel_clk)
   begin
      if(rising_edge(pixel_clk)) then
         if(rst = '1') then
            vcounter <= (others => '0');
         elsif(hcounter = HMAX) then
            if(vcounter = VMAX) then
               vcounter <= (others => '0');
            else
               vcounter <= std_logic_vector(unsigned(vcounter) + 1);
            end if;
         end if;
      end if;
   end process v_count;

   -- generate horizontal synch pulse
   -- when horizontal counter is between where the
   -- front porch ends and the synch pulse ends.
   -- The HS is active (with polarity SPP) for a total of 96 pixels.
   do_hs: process(pixel_clk)
   begin
      if(rising_edge(pixel_clk)) then
         if(hcounter >= HFP and hcounter < HSP) then
            HS <= SPP;
         else
            HS <= not SPP;
         end if;
      end if;
   end process do_hs;

   -- generate vertical synch pulse
   -- when vertical counter is between where the
   -- front porch ends and the synch pulse ends.
   -- The VS is active (with polarity SPP) for a total of 2 video lines
   -- = 2*HMAX = 1600 pixels.
   do_vs: process(pixel_clk)
   begin
      if(rising_edge(pixel_clk)) then
         if(vcounter >= VFP and vcounter < VSP) then
            VS <= SPP;
         else
            VS <= not SPP;
         end if;
      end if;
   end process do_vs;
   
end Behavioral;