library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity crcverify is
  port (
    CLK      : in  std_logic;
    DIN      : in  std_logic_vector(15 downto 0);
    DINEN    : in  std_logic;
    RESET    : in  std_logic;
    CRCVALID : out std_logic;
    DONE     : out std_logic);
end crcverify;

architecture Behavioral of crcverify is

  signal dinl   : std_logic_vector(15 downto 0) := (others => '0');
  signal dinenl, dinenll: std_logic                     := '0';
  signal resetl : std_logic                     := '0';

  signal crc8, crc8out  : std_logic_vector(31 downto 0) := (others => '0');
  signal crc16, crc16l, crc16out
    : std_logic_vector(31 downto 0) := (others => '0');
  signal crc16in : std_logic_vector(15 downto 0) := (others => '0');
  
  signal crcout : std_logic_vector(31 downto 0) := (others => '0');
  signal lcrcvalid , llcrcvalid: std_logic := '0';
  
  signal len  : std_logic_vector(15 downto 0) := (others => '0');
  signal bcnt, bcntl : std_logic_vector(15 downto 0) := (others => '0');

  signal ldone, lldone : std_logic := '0';

  signal bcnteq, bcntoneeq : std_logic := '0';
  
  component crc16_combinational
    port (
      D  : in  std_logic_vector(15 downto 0);
      CI : in  std_logic_vector(31 downto 0);
      CO : out std_logic_vector(31 downto 0));
  end component;

  component crc_combinational
    port ( CI : in  std_logic_vector(31 downto 0);
           D  : in  std_logic_vector(7 downto 0);
           CO : out std_logic_vector(31 downto 0));
  end component;

begin  -- Behavioral

  crc16in <= dinl(7 downto 0) & dinl(15 downto 8); 
  crc16_inst : crc16_combinational
    port map (
      D  => crc16in, 
      CI => crc16l,
      CO => crc16);

  crc_inst : crc_combinational
    port map (
      D  => dinl(15 downto 8),
      CI => crc16l,
      CO => crc8);

  crcout <= crc8out when len(0) = '1' else crc16out;

  main : process(CLK)
  begin
    if rising_edge(CLK) then

      dinl   <= DIN;
      dinenl <= DINEN;
      dinenll <= dinenl;
     resetl <= RESET;

      -- crc register
      if bcnt = X"0000" and dinenl = '1'  then
        len <= dinl; 
      end if;

      if bcnt = X"0000" then
        crc16l   <= (others => '1');
      else
        if dinenl = '1' then
          crc16l <= crc16;
        end if;
      end if;

      crc8out <= crc8;
      crc16out <= crc16;
      
      if resetl = '1' then
        bcnt   <= (others => '0');
      else
        if dinenl = '1' then
          bcnt <= bcnt + 2;
        end if;
      end if;

      bcntl <= bcnt; 
      if (bcnteq = '1'  or bcntoneeq = '1') and
        bcntl /= X"0000" and dinenll = '1'
      then
        lldone <= '1';
      else
        lldone <= '0'; 
      end if;
      
      if bcnt = len then
        bcnteq <= '1';
      else
        bcnteq <= '0'; 
      end if;

      if bcnt = len +1 then
        bcntoneeq <= '1';
      else
        bcntoneeq <= '0'; 
      end if;

      ldone <= lldone; 
      DONE <= ldone;
      
      if crcout = X"C704DD7B" then
        llCRCVALID <= '1';
      else
        llCRCVALID <= '0'; 
      end if;
      lcrcvalid <= llcrcvalid; 
      CRCVALID <= lcrcvalid; 
      
    end if;
  end process main; 


end Behavioral;
