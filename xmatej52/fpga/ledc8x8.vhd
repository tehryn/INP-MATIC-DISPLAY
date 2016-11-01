library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
--- Author: Matejka Jiri 
--- Date: 17. 10. 2016
--- Simulated: 17. 10. 2016
--- Tested: 18. 10. 2016
--- Module: INP project_1-8x8_LED_DISPLAY
entity ledc8x8 is
	port(
		SMCLK: in std_logic;
		RESET: in std_logic;
		LED: out std_logic_vector(7 downto 0);
		ROW: out std_logic_vector(7 downto 0)
	);
end ledc8x8;

architecture main of ledc8x8 is
    signal ce: std_logic := '0';
    signal counter: std_logic_vector(23 downto 0); --- 24 bits for our frequence if we want to have timer about 1 second
    signal output_M: std_logic_vector(7 downto 0) := "00000000"; --- vector to display M
	signal output_J: std_logic_vector(7 downto 0) := "00000000"; --- vector to dispay J
	signal row_inner: std_logic_vector(7 downto 0) := "10000000";

begin
	ctrl_cnt: process (SMCLK, RESET) --- setting counter - timer
	begin
		if RESET = '1' --- if reset, then 0 into coubter
		then
			counter <= "000000000000000000000000";
		elsif rising_edge(SMCLK) --- rising edge happens...
		then
			if counter(7 downto 0) = "11111111"
			then
				ce <= '1';
			else
				ce <= '0';
			end if;

			counter <= counter + 1; --- next state
		end if;
	end process;

	row_cnt: process (SMCLK, RESET, row_inner)
	begin
		if RESET = '1'
		then
			ROW <= "10000000";
			row_inner <= "10000000";
		elsif rising_edge(SMCLK) AND ce = '1'
		then
			case row_inner is
				when "10000000" => row_inner <= "01000000";
				when "00000001" => row_inner <= "10000000";
				when "00000010" => row_inner <= "00000001";
				when "00000100" => row_inner <= "00000010";
				when "00001000" => row_inner <= "00000100";
				when "00010000" => row_inner <= "00001000";
				when "00100000" => row_inner <= "00010000";
				when "01000000" => row_inner <= "00100000";
				when others => null;
			end case;
		end if;

		ROW <= row_inner;
	end process;
--- setting display fo M
	display_M: process (SMCLK, output_M) --- this will display M on top left
	begin
		if rising_edge(SMCLK) --- rising edge happens...
		then
			case row_inner is --- 0 means led on --> you can see, that letters we want to display are written by 0
				when "00000001" => output_M <= "01110111";
				when "00000010" => output_M <= "00100111";
				when "00000100" => output_M <= "01010111";
				when "00001000" => output_M <= "01110111";
				when "00010000" => output_M <= "01110111";
				when "00100000" => output_M <= "11111111";
				when "01000000" => output_M <= "11111111";
				when "10000000" => output_M <= "11111111";
				when others => null;
			end case;
		end if;
	end process;


--- Setting display for J
--- We must use whole display, or warnig happens during build, so we put J to right bottom	
	display_J: process (SMCLK, output_J) --- this will display J on bottom right
	begin 
		if rising_edge(SMCLK) --- this is clear...
		then
			case row_inner is --- you can see, that letters we want to display are written by 0
				when "00000001" => output_J <= "11111111";
				when "00000010" => output_J <= "11111111";
				when "00000100" => output_J <= "11111111";
				when "00001000" => output_J <= "11111110";
				when "00010000" => output_J <= "11111110";
				when "00100000" => output_J <= "11111110";
				when "01000000" => output_J <= "11110110";
				when "10000000" => output_J <= "11111001";
				when others => null;
			end case; --- ending case... this is clear too
		end if; --- ...
	end process; --- ...
	
--- this process will display J or M
	swap: process (SMCLK, RESET, output_M, output_J) --- this will swap between letters
	begin
		if RESET = '1' then --- reset signal
			LED <= "11111111";
			
		elsif rising_edge(SMCLK) --- rising edge happens

		then
			--- switching between outputs
			if counter(23) = '0' --- timer, I think its about 1.1 seconds

			then --- display M
				LED <= output_M; --- display M
			else --- otherwise dispaly J
				LED <= output_J; --- display J

			end if; 

		end if;
		
	end process;
	
end architecture;
