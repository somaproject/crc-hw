library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity crcappendtest is

end crcappendtest;

architecture Behavioral of crcappendtest is

  component crcappend
    port (
      CLK    : in  std_logic;
      DINEN  : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      DOUT   : out std_logic_vector(15 downto 0);
      DOUTEN : out std_logic
      );
  end component;

  signal CLK    : std_logic                     := '0';
  signal DINEN  : std_logic                     := '0';
  signal DIN    : std_logic_vector(15 downto 0) := (others => '0');
  signal DOUT   : std_logic_vector(15 downto 0) := (others => '0');
  signal DOUTEN : std_logic                     := '0';

  
begin  -- Behavioral

  CLK <= not CLK after 10 ns;

  crcappend_uut: crcappend
    port map (
      CLK    => CLK,
      DINEN  => DINEN,
      DIN => DIN,
      DOUT   => DOUT,
      DOUTEN => DOUTEN); 
    
  -- input data
  input_data    : process
    file din_file : text open read_mode is "din.dat";
    variable L     : line;
    variable enable : std_logic := '0';
    variable word  : std_logic_vector(15 downto 0);
  begin
    while not endfile(din_file) loop
      wait until rising_edge(CLK);
      readline(din_file, L);
      read(L, enable);
      hread(L, word);
      DINEN <= enable;
      DIN <= word; 
    end loop;
    wait; 

  end process input_data;
  
  -- output data verify
  output_data    : process
    file dout_file : text open read_mode is "dout.dat";
    variable L     : line;
    variable len : integer := 0;
    
    variable word  : std_logic_vector(15 downto 0);
  begin
    while not endfile(dout_file) loop
      readline(dout_file, L);
      read(L, len);      
      wait until rising_edge(CLK) and DOUTEN= '1';
      for i in 0 to (len+1)/2 loop
        hread(L, word);
        assert DOUT = word report "Error reading data word" severity Error;
        assert DOUTEN = '1' report "DOUTEN not high" severity Error;
        wait until rising_edge(CLK);
      end loop;  -- i
      
    end loop;
    report "End of Simulation" severity Failure;
    wait; 
    
  end process output_data;
  

end Behavioral;
