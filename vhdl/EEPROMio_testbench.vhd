

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT eepromio
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		spiclk : IN std_logic;
		din : IN std_logic_vector(15 downto 0);
		addr : IN std_logic_vector(10 downto 0);
		wr : IN std_logic;
		en : IN std_logic;         
		dout : OUT std_logic_vector(15 downto 0);
		done : OUT std_logic;
		esi : out std_logic;
		eso : in std_logic;
		esck : out std_logic;
		ecs : out std_logic
		);
	END COMPONENT;

	component test_EEPROM is
	    Generic (  FILEIN : string := "eeprom_in.dat"; 
	    			FILEOUT : string := "eeprom_out.dat"); 
	    Port ( CLK : in std_logic;
	           CS : in std_logic;
	           SCK : in std_logic;
			 SI : in std_logic;
			 SO : out std_logic; 
			 RESET : in std_logic;
			 SAVE : in std_logic);
	end component;

	SIGNAL clk :  std_logic := '0';
	SIGNAL spiclk :  std_logic;
	SIGNAL dout :  std_logic_vector(15 downto 0);
	SIGNAL din :  std_logic_vector(15 downto 0);
	SIGNAL addr :  std_logic_vector(10 downto 0);
	SIGNAL wr :  std_logic;
	SIGNAL en :  std_logic;
	SIGNAL done :  std_logic;
	signal reset : std_logic := '1';
	SIGNAL esi :  std_logic;
	SIGNAL eso :  std_logic := '0';
	signal esck : std_logic;
	signal ecs : std_logic; 
	signal cycle : integer := 0; 
	signal save : std_logic := '0';

 	constant clockperiod : time := 15 ns; 
BEGIN

	uut: eepromio PORT MAP(
		clk => clk,
		reset => reset, 
		spiclk => spiclk,
		dout =>dout,
		din => din,
		addr => addr,
		wr => wr,
		en => en,
		done => done,
		esi => esi,
		eso => eso,
		esck => esck,
		ecs => ecs
	);	
	
	fake_eeprom: test_EEPROM port map (
		CLK => clk,
		CS => ecs,
		SCK => esck,
		SI => esi,
		SO => eso,
		RESET => reset, 
		SAVE => save);
					

   clk <= not clk after clockperiod / 2; 

   -- input signals
   din <= "1001000011110011";
   reset <= '0' after 40 ns; 


   	

   tb : PROCESS(CLK, cycle) is
   BEGIN
      if rising_edge(CLK) then
	    cycle <= cycle + 1; 
	 end if; 

	 if cycle mod 640 = 0 then
	 	spiclk <= '1';
	 else
	 	spiclk <= '0';
	 end if; 

	 if cycle = 100 or cycle = 500000 then 
	 	en <= '1';
	 else 	
	 	en <= '0';
	 end if; 

	 if cycle < 499999 then 
	 	wr <= '0';
	 elsif cycle > 499999 and cycle < 1100000 then
	 	wr <= '1';

	 end if; 

	 if cycle < 499999 then
	 	ADDR <= "00000000011";
	else
		ADDR <= "00000000000";
	end if; 

	 if cycle = 1100000 then
	 	save <= '1';
	 else 
	 	save <= '0';
	 end if; 

   END PROCESS;

END;
