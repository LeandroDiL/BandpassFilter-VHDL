library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.std_logic_unsigned.all ;

entity volume_selector is
  port (
    signal Data_In_L, Data_In_R             : in std_logic_vector(23 downto 0);
    signal key2, key1, clock, reset         : in std_logic;
    signal Data_out_Left, Data_out_Right    : out std_logic_vector(23 downto 0);
    signal HEX0, HEX1                       : out std_logic_vector(0 to 6)
  );
end volume_selector ; 

architecture arch of volume_selector is
    type volume_value is (zero, plus_12dB, plus_9dB, plus_6dB, plus_3dB, minus_3dB, minus_6dB, minus_9dB, minus_12dB);
    signal current_volume : volume_value := zero;
	 
	 -- Questi segnali che rappresentano 1/8, 1/16, 1/64, 1/256, serviranno per andare a rappresentare attraverso opportune somme e moltiplicazioni x2 e x4 i volumi "dispari" : -3dB, -9dB, +3dB, +9dB.
	 -- Per i segnali "pari" : -12dB, -6dB, +6dB, +12dB basterà andare a moltiplicare o dividere per 2 e per 4 il segnale in ingresso
	 --signal Data_In_L_multiply : std_logic_vector(26 downto 0);
	 signal Data_In_L_shift2 : std_logic_vector(23 downto 0) := (others => '0');
	 --signal Data_In_L_shift2, Data_In_L_shift3, Data_In_L_shift4, Data_In_L_shift6, Data_In_L_shift8 : std_logic_vector(23 downto 0); 
    signal Data_In_L_minus_12dB, Data_In_L_minus_9dB, Data_In_L_minus_6dB, Data_In_L_minus_3dB, Data_In_L_plus_3dB, Data_In_L_plus_6dB, Data_In_L_plus_9dB, Data_In_L_plus_12dB : std_logic_vector(23 downto 0):= (others => '0'); 
    
    -- Applico lo stesso ragionamento fatto con il canale di sinistra anche ora per il canale di destra
	 --signal Data_In_R_multiply : std_logic_vector(26 downto 0);
	 signal Data_In_R_shift2 : std_logic_vector(23 downto 0) := (others => '0');
    --signal Data_In_R_shift2, Data_In_R_shift3, Data_In_R_shift4, Data_In_R_shift6, Data_In_R_shift8 : std_logic_vector(23 downto 0); 
    signal Data_In_R_minus_12dB, Data_In_R_minus_9dB, Data_In_R_minus_6dB, Data_In_R_minus_3dB, Data_In_R_plus_3dB, Data_In_R_plus_6dB, Data_In_R_plus_9dB, Data_In_R_plus_12dB : std_logic_vector(23 downto 0):= (others => '0');

begin
	 -- segnale sinistro
    -- Per ottenere -12dB ho diviso per 4 il segnale in entrata quindi facendo uno shift di due a destra
    Data_In_L_minus_12dB <= Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(22 downto 2);
	 
	 -- Per ottenere -3dB (e indirettamente anche -6dB) ho dapprima approssimato 1/sqrt(2) come 1/2 + 1/8 + 1/16 + 1/64 + 1/256 = 0.70703125 , pari a circa -3.01dB
	 Data_In_L_minus_6dB <= Data_In_L(23)&Data_In_L(23)&Data_In_L(22 downto 1); -- che corrisponderebbe al segnale Data_In_L_shift1 (non inizializzato per semplicità) ottenendo così anche il segnale a -6dB
	 Data_In_L_shift2 <= Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(22 downto 2);
	 --Data_In_L_shift3 <= Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(22 downto 3);
	 --Data_In_L_shift4 <= Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(22 downto 4);
	 --Data_In_L_shift6 <= Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(22 downto 6);
	 --Data_In_L_shift8 <= Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(23)&Data_In_L(22 downto 8);
	 Data_In_L_minus_3dB <= Data_In_L - Data_In_L_shift2;-- + Data_In_L_shift4; --+ Data_In_L_shift6; --+ Data_In_L_shift8;
	 --Data_In_L_multiply <= Data_in_L*"010";
	 --Data_In_L_minus_3dB <= Data_In_L_multiply(26)&Data_In_L_multiply(24 downto 2);
	 
	 -- Per ottenere -9dB parto dal segnale Data_In_L_minus_3dB e dopo divido per 2 facendo uno shift di uno a destra così da ottenere 0.353515625 = -9.031828dB
	 Data_In_L_minus_9dB <= Data_In_L_minus_3dB(23)&Data_In_L_minus_3dB(23)&Data_In_L_minus_3dB(22 downto 1);
	 
	 -- Per ottenere +3dB, che corrisponde a moltiplicare per sqrt(2), mi basta prendere il segnale moltiplicato per 1/sqrt(2) ovvero Data_In_L_minus_3dB e moltiplicarlo per 2 ovvere fare shift a sinistra di uno
	 Data_In_L_plus_3dB <= Data_In_L_minus_3dB(23)&Data_In_L_minus_3dB(21 downto 0)&'0';
	 
	 -- Per ottenere +6dB moltiplico per 2 quindi faccio uno shift di uno a sinistra
	 Data_In_L_plus_6dB <= Data_In_L(23)&Data_In_L(21 downto 0)&'0';
	 
	 -- Per ottenere +9dB, che corrisponde a moltiplicare per sqrt(2)*2, mi basta prendere il segnale moltiplicato per 1/sqrt(2) ovvero Data_In_L_minus_3dB e moltiplicarlo per 4 ovvere fare shift a sinistra di due
	 Data_In_L_plus_9dB <= Data_In_L_minus_3dB(23)&Data_In_L_minus_3dB(20 downto 0)&"00";
	 
	 -- Per ottenere +12dB moltiplico per 4 quindi faccio uno shift di due a sinistra
	 Data_In_L_plus_12dB <= Data_In_L(23)&Data_In_L(20 downto 0)&"00";
	 
	 
	 -- stesso discorso per il segnale di destra
    Data_In_R_minus_12dB <= Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(22 downto 2);
	 Data_In_R_minus_6dB <= Data_In_R(23)&Data_In_R(23)&Data_In_R(22 downto 1); -- che corrisponderebbe al segnale Data_In_L_shift1 (non inizializzato per semplicità) ottenendo così anche il segnale a -6dB
	 Data_In_R_shift2 <= Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(22 downto 2);
	 --Data_In_R_shift3 <= Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(22 downto 3);
	 --Data_In_R_shift4 <= Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(22 downto 4);
	 --Data_In_R_shift6 <= Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(22 downto 6);
	 --Data_In_R_shift8 <= Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(23)&Data_In_R(22 downto 8);
	 Data_In_R_minus_3dB <= Data_In_R - Data_In_R_shift2;-- + Data_In_R_shift4; -- + Data_In_R_shift6 + Data_In_R_shift8;
	 --Data_In_R_multiply <= Data_in_R*"010";
	 --Data_In_R_minus_3dB <= Data_In_R_multiply(26)&Data_In_R_multiply(24 downto 2);
	 Data_In_R_minus_9dB <= Data_In_R_minus_3dB(23)&Data_In_R_minus_3dB(23)&Data_In_R_minus_3dB(22 downto 1);
	 Data_In_R_plus_3dB <= Data_In_R_minus_3dB(23)&Data_In_R_minus_3dB(21 downto 0)&'0';
	 Data_In_R_plus_6dB <= Data_In_R(23)&Data_In_R(21 downto 0)&'0';
	 Data_In_R_plus_9dB <= Data_In_R_minus_3dB(23)&Data_In_R_minus_3dB(20 downto 0)&"00";
	 Data_In_R_plus_12dB <= Data_In_R(23)&Data_In_R(20 downto 0)&"00";
    
    
    process (clock) is -- Tabella degli stati
            variable next_volume :  volume_value := zero;
            variable volume_up, volume_down, release_key1, release_key2 : std_logic := '0';
        BEGIN
            IF rising_edge(clock) then
					case (reset) is
						when '1' => next_volume := zero;
						when '0' =>
						 IF (NOT(key2) AND release_key2) = '1' then -- release è a 1 se il pulsante è stato rilasciato dopo essere stato premuto
							  release_key2 := '0';
							  volume_up := '1';
						 ELSIF (NOT(key1) AND release_key1) = '1' then
							  release_key1 := '0';
							  volume_down := '1';
						 ELSIF (key2 AND NOT(release_key2)) = '1' then
							  release_key2 := '1'; -- Se il tasto è stato rilasciato possiamo mettere a 1 il release
						 ELSIF key1 = '1' then
							  release_key1 := '1'; -- Se il tasto è stato rilasciato possiamo mettere a 1 il release
						 END IF;
					END CASE;
           
                case current_volume is
                    WHEN plus_12dB =>
                        HEX0 <= "1001100"; -- 4
                        HEX1 <= "1111111";
                        IF volume_up = '1' THEN
                            next_volume := plus_12dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := plus_9dB;
                            volume_down := '0';
                        END IF;
                    WHEN plus_9dB =>
                        HEX0 <= "0000110"; -- 3
                        HEX1 <= "1111111";
                        IF volume_up = '1' THEN 
                            next_volume := plus_12dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := plus_6dB;
                            volume_down := '0';
                        END IF;
                    WHEN plus_6dB =>
                        HEX0 <= "0010010"; -- 2
                        HEX1 <= "1111111";
                        IF volume_up = '1' THEN 
                            next_volume := plus_9dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := plus_3dB;
                            volume_down := '0';
                        END IF;
                    WHEN plus_3dB =>
                        HEX0 <= "1001111"; -- 1
                        HEX1 <= "1111111";
                        IF volume_up = '1' THEN 
                            next_volume := plus_6dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := zero;
                            volume_down := '0';
                        END IF;
                    WHEN zero =>
                        HEX0 <= "0000001"; -- 0
                        HEX1 <= "1111111";
                        IF volume_up = '1' THEN 
                            next_volume := plus_3dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := minus_3dB;
                            volume_down := '0';
                        END IF;
                    WHEN minus_3dB =>
                        HEX0 <= "1001111"; -- 1
                        HEX1 <= "1111110";
                        IF volume_up = '1' THEN 
                            next_volume := zero;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := minus_6dB;
                            volume_down := '0';
                        END IF;
                    WHEN minus_6dB =>
                        HEX0 <= "0010010"; -- 2
                        HEX1 <= "1111110";
                        IF volume_up = '1' THEN 
                            next_volume := minus_3dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := minus_9dB;
                            volume_down := '0';
                        END IF;
                    WHEN minus_9dB =>
                        HEX0 <= "0000110"; -- 3
                        HEX1 <= "1111110";
                        IF volume_up = '1' THEN 
                            next_volume := minus_6dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := minus_12dB;
                            volume_down := '0';
                        END IF;
                    WHEN minus_12dB =>
                        HEX0 <= "1001100"; -- 4
                        HEX1 <= "1111110";
                        IF volume_up = '1' THEN 
                            next_volume := minus_9dB;
                            volume_up := '0';
                        ELSIF volume_down = '1' THEN
                            next_volume := minus_12dB;
                            volume_down := '0';
                        END IF;
                END CASE;
                current_volume <= next_volume; -- Cambio il volume secondo la tabella degli stati qui sopra.
            END IF;
        END PROCESS;
        
        with current_volume select Data_out_Left <=
        
            Data_In_L_plus_12dB     when plus_12dB,
            Data_In_L_plus_9dB      when plus_9dB,
            Data_In_L_plus_6dB      when plus_6dB,
            Data_In_L_plus_3dB      when plus_3dB,
            Data_In_L               when zero,
            Data_In_L_minus_3dB     when minus_3dB,
            Data_In_L_minus_6dB     when minus_6dB,
            Data_In_L_minus_9dB 		when minus_9dB,
            Data_In_L_minus_12dB    when minus_12dB;
        
        with current_volume select Data_out_Right <=
        
            Data_In_R_plus_12dB     when plus_12dB,
            Data_In_R_plus_9dB      when plus_9dB,
            Data_In_R_plus_6dB      when plus_6dB,
            Data_In_R_plus_3dB      when plus_3dB,
            Data_In_R               when zero,
            Data_In_R_minus_3dB     when minus_3dB,
            Data_In_R_minus_6dB     when minus_6dB,
            Data_In_R_minus_9dB 		when minus_9dB,
            Data_In_R_minus_12dB    when minus_12dB;
end architecture ;