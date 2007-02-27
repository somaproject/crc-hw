library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity crcappend is
  port (
    CLK      : in  std_logic;
    DINEN : in std_logic;
    DIN : in std_logic_vector(15 downto 0);
    DOUT : out std_logic_vector(15 downto 0);
    DOUTEN : out std_logic
    );

end crcappend;


architecture Behavioral of crcappend is

  signal dinl, dinl1, dinl2 : std_logic_vector(15 downto 0) := (others => '0');

  -- frame length 
  signal len : std_logic_vector(15 downto 0) := (others => '0');
  signal lenl : std_logic_vector(15 downto 0) := (others => '0');
  signal bcnt : std_logic_vector(15 downto 0) := (others => '0');

  
  signal dinenl : std_logic := '0';

  signal den, denl : std_logic := '0';
  signal ldout : std_logic_vector(15 downto 0) := (others => '0');

  
  signal osel, osell : integer range 0 to 6 := 0;

  -- crc signals
  signal crc8, crc8out : std_logic_vector(31 downto 0) := (others => '0');
  signal crc16, crc16out : std_logic_vector(31 downto 0) := (others => '0');
  signal crc16l : std_logic_vector(31 downto 0) := (others => '0');
  signal crcen : std_logic := '0';
  signal crc16outnrev : std_logic_vector(31 downto 0);
  signal crc8outnrev : std_logic_vector(31 downto 0);
  signal crc16in : std_logic_vector(15 downto 0) := (others => '0');

  
  -- state machine
  type states is (none, lenout, dataout, crc16oh, crc16ol,
                  crc8oh, crc8om, crc8ol, donewait);

  signal cs, ns : states := none;


  -- components
  component crc16_combinational 
  port (
    D  : in  std_logic_vector(15 downto 0);
    CI : in  std_logic_vector(31 downto 0);
    CO : out std_logic_vector(31 downto 0));
  end component;

  component crc_combinational 
  port (
    D  : in  std_logic_vector(7 downto 0);
    CI : in  std_logic_vector(31 downto 0);
    CO : out std_logic_vector(31 downto 0));
  end component;

begin  -- Behavioral

  crc8inst: crc_combinational
    port map (
      D  => dinl1(15 downto 8),
      CI => crc16l,
      CO => crc8);

  crc16in <= dinl1(7 downto 0) & dinl1(15 downto 8); 
           
  crc16inst: crc16_combinational
    port map (
      D  => crc16in, 
      CI => crc16l,
      CO => crc16);
  
  ldout <= lenl when osell = 0 else
           dinl2 when osell = 1 else
           crc16outnrev(7 downto 0 )
           & crc16outnrev(15 downto 8)
                      when osell = 2 else
           crc16outnrev(23 downto 16 )
           & crc16outnrev(31 downto 24)
                      when osell = 3 else
           dinl2(15 downto 8) & 
           crc8outnrev(7 downto 0) when osell = 4 else
           crc8outnrev(15 downto 8) & crc8outnrev(23 downto 16)
                         when osell = 5 else
           crc8outnrev(31 downto 24) & X"00" when osell = 6
           else X"0000";

  crcrev: for i in 0 to 31 generate
    crc16outnrev(i) <= not crc16out(31 -i);
    crc8outnrev(i) <= not crc8out(31 -i);
    
  end generate crcrev;

  
  main: process(CLK)
    begin
      if rising_edge(CLK) then
        cs <= ns;
        
        -- input latch
        dinl <= DIN;
        dinenl <= DINEN;

        -- output latches
        DOUT <= ldout;
        DOUTEN <= denl;
        denl <= den;

        -- crc registers

        if crcen = '1' then
          
          crc8out <= crc8;
          crc16out <= crc16;
        end if;

        
        if cs = none then
          crc16l <= (others => '1');
        else
          if crcen = '1' then
            crc16l <= crc16; 
          end if;
        end if;

        -- misc registers
        dinl1 <= dinl;
        dinl2 <= dinl1;

        if cs = none then
          len <= dinl;
        end if;

        lenl <= len + 4;

        osell <= osel; 
        if cs = none then
          bcnt <= (others => '0');
        else
          if cs= dataout then
            bcnt <= bcnt + 2; 
          end if; 
        end if;
      end if;
    end process main;

    fsm: process(cs, len, bcnt, dinenl)
    begin 
      case cs is
        when none =>
          osel <= 0;
          den <= '0';
          crcen <= '0';
          if dinenl = '1' then
            ns <= lenout;
          else
            ns <= none;
          end if;

        when lenout =>
          osel <= 0;
          den <= '1';
          crcen <= '0';
          ns <= dataout;
          
        when dataout =>
          osel <= 1; 
          den <= '1';
          crcen <= '1';
          if bcnt +2 = len -1 then
            ns <= crc8oh;
          elsif bcnt +2  = len then
            ns <= crc16oh;
          else
            ns <= dataout; 
          end if;
          
        when crc16oh =>
          osel <= 2;
          den <= '1';
          crcen <= '0';
          ns <= crc16ol; 
          
        when crc16ol =>
          osel <= 3;
          den <= '1';
          crcen <= '0';
          ns <= donewait; 
        
        when crc8oh =>
          osel <= 4;
          den <= '1';
          crcen <= '1';
          ns <= crc8om; 
        
        when crc8om =>
          osel <= 5;
          den <= '1';
          crcen <= '0';
          ns <= crc8ol; 
        
        when crc8ol =>
          osel <= 6;
          den <= '1';
          crcen <= '0';
          ns <= donewait;
          
        when donewait =>
          osel <= 0;
          den <= '0';
          crcen <= '0';
          if dinenl = '1' then
            ns <= donewait;
          else
            ns <= none; 
          end if;

          
        when others =>
          osel <= 0;
          den <= '0';
          crcen <= '0';
          ns <= none; 
      end case;
    end process fsm; 
end Behavioral;
