library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.std_logic_unsigned.all ;
	 use ieee.numeric_std.all;

entity multiply_and_add is
  generic ( 
				k : natural;
				s_k : natural;
				const : signed
				);

  port (
    SIGNAL s, s2 : IN STD_LOGIC_VECTOR(42 downto 0);
    SIGNAL ks : OUT STD_LOGIC_VECTOR(42 downto 0)
  );
end multiply_and_add ; 

architecture arch of multiply_and_add is
  SIGNAL s_x_consti : signed(s_k-1 downto 0);                   
  signal vector_s_x_consti : std_logic_vector(s_k-1 downto 0);
  signal signed_vector_s : signed(42 downto 0);
  
begin
	signed_vector_s <= signed(s(42 downto 0));
	s_x_consti <= signed_vector_s*const;
	
	vector_s_x_consti <= std_logic_vector(s_x_consti);
	ks <= ((vector_s_x_consti(s_k-1)&vector_s_x_consti(s_k-3 downto s_k-44)) + s2);
	 
end architecture ;