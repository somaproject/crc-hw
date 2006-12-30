library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity unifiedtest is

end unifiedtest;

architecture Behavioral of unifiedtest is

  component crcappend
    port (
      CLK    : in  std_logic;
      DINEN  : in  std_logic;
      DIN    : in  std_logic_vector(15 downto 0);
      DOUT   : out std_logic_vector(15 downto 0);
      DOUTEN : out std_logic
      );
  end component;

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
  signal DINEN    : std_logic                     := '0';
  signal DIN      : std_logic_vector(15 downto 0) := (others => '0');
  signal DOUT     : std_logic_vector(15 downto 0) := (others => '0');
  signal DOUTEN   : std_logic                     := '0';
  signal VERIFYDIN : std_logic_vector(15 downto 0) := (others => '0');
  signal CRCVALID : std_logic                     := '0';
  signal DONE     : std_logic                     := '0';
  signal RESET    : std_logic                     := '0';

  signal corruptword : std_logic := '0';

begin  -- Behavioral

  CLK <= not CLK after 10 ns;

  VERIFYDIN <= DOUT when corruptword = '0' else
               DOUT(15 downto 1) & not DOUT(0);
  
  crcappend_uut : crcappend
    port map (
      CLK    => CLK,
      DINEN  => DINEN,
      DIN    => DIN,
      DOUT   => DOUT,
      DOUTEN => DOUTEN);

  crcverify_uut : crcverify
    port map (
      CLK      => CLK,
      DIN      => VERIFYDIN,
      DINEN    => DOUTEN,
      RESET    => RESET,
      CRCVALID => CRCVALID,
      DONE     => DONE);

  -- input data
  input_data        : process
    file din_file   : text open read_mode is "din.dat";
    variable L      : line;
    variable enable : std_logic := '0';
    variable word   : std_logic_vector(15 downto 0);
  begin
    while not endfile(din_file) loop
      wait until rising_edge(CLK);
      readline(din_file, L);
      read(L, enable);
      hread(L, word);
      DINEN <= enable;
      DIN   <= word;
    end loop;
    wait;

  end process input_data;

  -- corrupt and verify
  verify_data         : process
    file results_file : text open read_mode is "results.dat";
    variable L        : line;
    variable corrupt  : integer := 0;
    variable corruptpos     : integer := 0;
  begin
    while not endfile(results_file) loop
      wait until rising_edge(CLK) and DINEN = '1';
      readline(results_file, L);
      read(L, corrupt);

      if corrupt = 1 then
        read(L, corruptpos);
        for i in 0 to corruptpos - 1 loop
          wait until rising_edge(CLK);
        end loop;  -- i
        corruptword <= '1';
        wait until rising_edge(CLK);
        corruptword <= '0';
      end if;

      wait until rising_edge(CLK) and DONE = '1';
      if corrupt = 1 then
        assert CRCVALID = '0' report
          "CRC is valid on a corrupted frame" severity error;
      else
        assert CRCVALID = '1' report
          "CRC is invalid on a non-corrupted frame" severity error;

      end if;
      RESET <= '1';
      wait until rising_edge(CLK);
      RESET <= '0';
      
      
    end loop;

    report "End of Simulation" severity Failure;
    wait;

  end process verify_data;

end Behavioral;
