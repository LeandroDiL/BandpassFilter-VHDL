 library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
    use ieee.std_logic_unsigned.all;
    
entity bandpass is
  port (
    Data_In : IN std_logic_vector(23 downto 0)  := (others => '0');
    clock, read_s                               : IN std_logic := '0';
    Data_out                                    : OUT std_logic_vector(23 downto 0)
  );
end bandpass ; 

architecture arch of bandpass is
CONSTANT zero : STD_LOGIC_VECTOR(42 downto 0) := (others => '0');
SIGNAL Compl : STD_LOGIC_VECTOR(42 downto 24) := (others => '0');
SIGNAL s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25 : STD_LOGIC_VECTOR(42 downto 0);
begin
    
    Compl <= (others => Data_In(23));
    
    -- Per ridurre la logica utilizzata, invece di andare a moltiplicare per coefficienti negativi ho negato il segnale in entrata quando necessario facendo complemento a 2 
	 -- ma senza aggiungere 1 in quanto non porterebbe ad un cambiamento significativo all'interno di un segnale a 24 bit 
	 
    -- Segnali del ramo superiore:
    negk6 : entity work.multiply_and_add generic map (8, 51, "00111011") port map (not(s17), Compl&Data_In, s1);
    negk5 : entity work.multiply_and_add generic map (8, 51, "01101011") port map (s15, s1, s2);
    negk4 : entity work.multiply_and_add generic map (8, 51, "01101111") port map (not(s13), s2, s3);
    negk3 : entity work.multiply_and_add generic map (8, 51, "01111110") port map (s11, s3, s4);
    negk2 : entity work.multiply_and_add generic map (13, 56, "0111111111110") port map (not(s9), s4, s5);
    negk1 : entity work.multiply_and_add generic map (13, 56, "0111111111111") port map (s7, s5, s6);
    
	 
    reg_s7  : entity work.register_43bit port map (s6, clock, read_s, s7);
    reg_s9  : entity work.register_43bit port map (s8, clock, read_s, s9);
    reg_s11 : entity work.register_43bit port map (s10, clock, read_s, s11);
    reg_s13 : entity work.register_43bit port map (s12, clock, read_s, s13);
    reg_s15 : entity work.register_43bit port map (s14, clock, read_s, s15);
    reg_s17 : entity work.register_43bit port map (s16, clock, read_s, s17);
    
    -- Segnali del ramo centrale (da destra verso sinistra)
    posk1 : entity work.multiply_and_add generic map (13, 56, "0111111111111") port map (not(s6), s7, s8);
    posk2 : entity work.multiply_and_add generic map (13, 56, "0111111111110") port map (s5, s9, s10);
    posk3 : entity work.multiply_and_add generic map (8, 51, "01111110") port map (not(s4), s11, s12);
    posk4 : entity work.multiply_and_add generic map (8, 51, "01101111") port map (s3, s13, s14);
    posk5 : entity work.multiply_and_add generic map (8, 51, "01101011") port map (not(s2), s15, s16);
    posk6 : entity work.multiply_and_add generic map (8, 51, "00111011") port map (s1, s17, s18);
    
    -- Segnali del ramo inferiore
    posv7 : entity work.multiply_and_add generic map (6, 49, "000001") port map (not(s18), zero, s19);
    posv6 : entity work.multiply_and_add generic map (6, 49, "000011") port map (not(s16), s19, s20);
    posv5 : entity work.multiply_and_add generic map (8, 51, "00010001") port map (not(s14), s20, s21);
    posv4 : entity work.multiply_and_add generic map (7, 50, "0000101") port map (not(s12), s21, s22);
    posv3 : entity work.multiply_and_add generic map (12, 55, "000000001101") port map (s10, s22, s23);
    posv2 : entity work.multiply_and_add generic map (15, 58, "000000000000010") port map (s8, s23, s24);
    posv1 : entity work.multiply_and_add generic map (27, 70, "000000000000000000000001101") port map(not(s6), s24, s25);
    
    -- Uscita
    Data_out <= s25(42)&s25(22 downto 0);
    
    
end architecture ;