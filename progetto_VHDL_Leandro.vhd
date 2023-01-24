LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
USE ieee.numeric_std.all;

ENTITY progetto_VHDL_Leandro IS
   PORT (
            CLOCK_50, CLOCK2_50, AUD_DACLRCK   : IN    STD_LOGIC;
            AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT  : IN    STD_LOGIC;
            KEY                                : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
            SW                                 : IN    STD_LOGIC_VECTOR(0 DOWNTO 0);
            FPGA_I2C_SDAT                      : INOUT STD_LOGIC;
            FPGA_I2C_SCLK, AUD_DACDAT, AUD_XCK : OUT   STD_LOGIC;
            HEX0, HEX1                         : OUT STD_LOGIC_VECTOR(0 to 6)
        );
END progetto_VHDL_Leandro;

ARCHITECTURE Top_Level OF progetto_VHDL_Leandro IS
   COMPONENT clock_generator
      PORT( CLOCK2_50 : IN STD_LOGIC;
            reset    : IN STD_LOGIC;
            AUD_XCK  : OUT STD_LOGIC);
   END COMPONENT;

   COMPONENT audio_and_video_config
      PORT( CLOCK_50, reset : IN    STD_LOGIC;
            I2C_SDAT        : INOUT STD_LOGIC;
            I2C_SCLK        : OUT   STD_LOGIC);
   END COMPONENT;   

   COMPONENT audio_codec
      PORT( CLOCK_50, reset, read_s, write_s               : IN  STD_LOGIC;
            writedata_left, writedata_right                : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
            AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK : IN  STD_LOGIC;
            read_ready, write_ready                        : OUT STD_LOGIC;
            readdata_left, readdata_right                  : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
            AUD_DACDAT                                     : OUT STD_LOGIC);
   END COMPONENT;
   SIGNAL read_ready, write_ready, read_s, write_s  : STD_LOGIC;
   SIGNAL readdata_left, readdata_right             : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL writedata_left, writedata_right           : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL sine_left, sine_right                     : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL out_filtro_left, out_filtro_right         : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL in_volume_left, in_volume_right           : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL reset, clock                              : STD_LOGIC;
BEGIN
   reset <= NOT(KEY(0));
	
   left_filter  : entity work.bandpass port map(readdata_left, clock_50, read_s, out_filtro_left);
	right_filter : entity work.bandpass port map(readdata_right, clock_50, read_s, out_filtro_right);
   
   in_volume_left  <=   out_filtro_left when SW(0) = '1'
                        else readdata_left;
   in_volume_right <=   
								out_filtro_right  when SW(0) = '1'
                        else readdata_right;

   vol_sel : entity work.volume_selector port map(in_volume_left, in_volume_right, KEY(2), KEY(1), clock_50, reset, writedata_left, writedata_right, HEX0, HEX1);
	
   read_s <= read_ready;
   write_s <= read_ready AND write_ready;
   
   my_clock_gen: clock_generator PORT MAP (CLOCK2_50, reset, AUD_XCK);

   cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, FPGA_I2C_SDAT, FPGA_I2C_SCLK);
   codec: audio_codec PORT MAP (CLOCK_50, reset, read_s, write_s, writedata_left, 
	                             writedata_right, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK,
										  AUD_DACLRCK, read_ready, write_ready, readdata_left, 
										  readdata_right, AUD_DACDAT);   
END Top_Level;