library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity register_43bit is
  port (
    D : IN STD_LOGIC_VECTOR(42 downto 0);
    clock, read_s : IN std_logic;
    A : OUT std_logic_vector(42 downto 0)
  ) ;
end register_43bit ; 

architecture arch of register_43bit is
    SIGNAL reg : std_logic_vector(85 downto 0) := (others => '0');
begin
  rst : process (clock) is
    begin
        if rising_edge(clock) then
            if (read_s='1') then
                reg <= reg(42 downto 0)&D;
            end if;
        end if;
  end process;
  A <= reg(85 downto 43);
end architecture ;