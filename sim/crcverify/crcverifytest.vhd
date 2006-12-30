library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.TextIO.all;

entity crcverifytest is

end crcverifytest;

architecture Behavioral of crcverifytest is

  component crcverify
    port (
      CLK      : in  std_logic;
      DIN      : in  std_logic_vector(15 downto 0);
      DINEN    : in  std_logic;
      RESET    : in  std_logic;
      CRCVALID : out std_logic;
      DONE     : out std_logic);
  end component;

  signal CLK      : std_logic                     := '0';
  signal DIN      : std_logic_vector(15 downto 0) := (others => '0');
  signal DINEN    : std_logic                     := '0';
  signal RESET    : std_logic                     := '0';
  signal CRCVALID : std_logic                     := '0';
  signal DONE     : std_logic                     := '0';

  
begin  -- Behavioral
  crcverify_uut: crcverify
    port map (
      CLK      => CLK,
      DIN      => DIN,
      DINEN    => DINEN,
      RESET    => RESET,
      CRCVALID => CRCVALID,
      DONE     => DONE); 

  -- clock
  clk <= not clk after 10 ns;

  
  -- read in data
  process
    file datafile     : text;
    variable L       : line;
    variable n : integer := 0;
    variable corrupted : integer := 1;
    variable word : std_logic_vector(15 downto 0) := (others => '0');
    
    begin
      file_open(datafile, "din.dat");
      while not endfile(datafile) loop
        DINEN <= '0'; 
        wait for 1 us;
        wait until rising_edge(CLK);
        RESET <= '1'; 
        wait until rising_edge(CLK);
        RESET <= '0'; 
        wait until rising_edge(CLK);
        readline(datafile, L);
        read(L, corrupted); 
        read(L, n);
        
        for i in 1 to ((n+1)/2 + 1) loop
          hread(L, word);
          DIN <= word; 
          DINEN <= '1'; 
          wait until rising_edge(CLK);
        end loop;  -- i
        DINEN <= '0'; 
        wait until rising_edge(CLK) and DONE = '1';
        if CRCVALID = '1' then
          assert corrupted = 0 report "Error reading crc" severity Error; 
        else
          assert corrupted = 1 report "Error reading crc" severity Error; 
        end if;

      end loop;
      wait for 1 us;
      
      report "End of Simulation" severity Failure;
      
    end process; 

end Behavioral;

