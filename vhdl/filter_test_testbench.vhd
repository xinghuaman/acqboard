
-- VHDL Test Bench Created from source file filter_test.vhd -- 16:44:45 01/07/2003
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
USE std.textio.ALL;

library UNISIM;
use UNISIM.VComponents.all;

ENTITY testbench IS
END testbench;

-- Filter_test testbench --------------------------------------
--  Filter test bench. This essentially wires-up all the components, but should
--  be easier to get data out of then a real implementation, as the actual one
--  only exposes the 8B/10B encoded output. 
-- 
--  The input here (in addition to the requisite 32 MHz CLKIN) will be
--  a system which reads in an array of 10 14-bit 2s-complement integers
--  from a text file, a line at a time, triggered by the going high of CONVST. 
--  
ARCHITECTURE behavior OF testbench IS 

	COMPONENT filter_test
	PORT(
		clkin : IN std_logic;
		resetin : IN std_logic;
		datain : IN std_logic_vector(13 downto 0);          
		convst : OUT std_logic;
		oeb : OUT std_logic_vector(9 downto 0);
		outbyteout : OUT std_logic;
		macrnd : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL convst :  std_logic := '1';
	SIGNAL clkin :  std_logic := '1';
	SIGNAL resetin :  std_logic := '1';
	SIGNAL datain :  std_logic_vector(13 downto 0) := "00000000000000";
	SIGNAL oeb :  std_logic_vector(9 downto 0);
	SIGNAL outbyteout :  std_logic;
	SIGNAL macrnd, macrndl :  std_logic_vector(15 downto 0);
	subtype dataword is integer range -8192 to 8191;
	type inputarray is array (0 to 9) of dataword;
			signal dataouts : inputarray := (others => 0); 

	signal convstcount : integer := 0;
	signal outbytecount : integer := 0; 

BEGIN

	uut: filter_test PORT MAP(
		convst => convst,
		clkin => clkin,
		resetin => resetin,
		datain => datain,
		oeb => oeb,
		outbyteout => outbyteout,
		macrnd => macrnd
	);


-- *** Test Bench - User Defined Section ***

   resetin <= '0' after 50 ns;

	simulator_in: process (CONVST, oeb) is
			--subtype dataword is integer range -8192 to 8191;
			file input_file : text open read_mode is "\\shannon\HostFS\acquisition\development\acqboard\dsp\simulation\test.rtl.dat";
			variable tempdata: dataword;
			variable iline: line; 
			

		begin
			if rising_edge(convst) then
				readline(input_file, iline);
				for channelnumber in 0 to 9 loop
					read(iline, tempdata);
					dataouts(channelnumber) <= tempdata; 
				end loop; 
				if convstcount = 7 then
					convstcount <= 0;
				else
					convstcount <= convstcount + 1;
				end if; 
			end if;

			if oeb(0) = '0' then 
				datain <= conv_std_logic_vector(dataouts(0), 14) after 10 ns;
			elsif oeb(1) = '0' then 
				datain <= conv_std_logic_vector(dataouts(1), 14) after 10 ns;
			elsif oeb(2) = '0' then 
				datain <= conv_std_logic_vector(dataouts(2), 14) after 10 ns;
			elsif oeb(3) = '0' then 
				datain <= conv_std_logic_vector(dataouts(3), 14) after 10 ns;
			elsif oeb(4) = '0' then 
				datain <= conv_std_logic_vector(dataouts(4), 14) after 10 ns;
			elsif oeb(5) = '0' then 
				datain <= conv_std_logic_vector(dataouts(5), 14) after 10 ns;
			elsif oeb(6) = '0' then 
				datain <= conv_std_logic_vector(dataouts(6), 14) after 10 ns;
			elsif oeb(7) = '0' then 
				datain <= conv_std_logic_vector(dataouts(7), 14) after 10 ns;
			elsif oeb(8) = '0' then 
				datain <= conv_std_logic_vector(dataouts(8), 14) after 10 ns;
			elsif oeb(9) = '0' then 
				datain <= conv_std_logic_vector(dataouts(9), 14) after 10 ns;
			else 
				datain <= "ZZZZZZZZZZZZZZ" after 10 ns;
			end if; 

	  	end process simulator_in;

		simulator_out :process (outbyteout) is
			 file output_file : text open write_mode is "\\shannon\HostFS\acquisition\development\acqboard\dsp\simulation\output.dat";
			 variable oline : line; 
		begin
			 if rising_edge(outbyteout) then
			 	-- crude hack to sample the output at the right times
			 	if  outbytecount = 2 or
						outbytecount = 4 or
						outbytecount = 6 or
						outbytecount = 8 or
						outbytecount = 10 or
						outbytecount = 12 or
						outbytecount = 14 or
						outbytecount = 16 or
						outbytecount = 18 or
						outbytecount = 0 then
						macrndl <= macrnd;
						write(oline, conv_integer(macrnd));
						write(oline, ' '); 


				end if; 
			  	if outbytecount = 22 then
					writeline(output_file, oline); 
				end if; 

				if outbytecount = 24 then
					outbytecount <= 0;
				else
					outbytecount <= outbytecount + 1;
				end if; 
			 end if;
		end process simulator_out; 

	  clk_one: process(clkin) is
     begin
             if clkin = '1' then 
                     clkin <= '0' after 15625 ps, '1' after 31250 ps;  
                     --clkin <= '0' after 40000 ps, '1' after 80000 ps;  

             end if;
     end process clk_one; 

-- *** End Test Bench - User Defined Section ***

END;
