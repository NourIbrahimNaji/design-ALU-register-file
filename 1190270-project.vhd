--**************************************************************************************************************
--                                                      ALU
--**************************************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all; 

entity alu is
port ( A, B: in std_logic_vector (31 downto 0);
opcode: in std_logic_vector(5 downto 0);
Result: out std_logic_vector (31 downto 0));         
end entity alu;	

architecture dataopcode of alu is	 
begin 
	process(A,B,opcode)
	variable A_int , B_int ,avg: integer ;
	begin 
		case opcode is
			when "001000" => Result <= A + B;
			when "001001" => Result <= A - B;
			when "000010" => Result <= abs(A);
			when "001010" => Result <= -A;
			when "001100" => if (A > B) then  result <= A;
			    elsif(A < B) then result <= B; 
				else NULL ;
				end if ;
			when "000001" => if (A > B) then  result <= B;
			    elsif(A < B) then result <= A; 
				else NULL ;
				end if ;
			when "001101" => 
			A_int := conv_integer(signed(A));
	         B_int := conv_integer(signed(B));
	         avg   := (A_int + B_int)/2;
			Result <= conv_std_logic_vector(avg, 32); 
			when "000101" => Result <= not (A);
			when "000100" => Result <= A or B;
			when "001011" => Result <= A and B;
			when "001111" => Result <= A xor B;
		    when others => NULL;
end case;
end process;	
end architecture dataopcode;	
--**************************************************************************************************************
--                                                      RAM 
--**************************************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
use IEEE.std_logic_unsigned.all;

entity RAM32x32 is 
   port ( Address1, Address2 ,Address3: in std_logic_vector (4 downto 0); 
   enable : in std_logic;
   input : in  std_logic_vector (31 downto 0);
   clk : in  std_logic ;
   output1, output2 : out std_logic_vector (31 downto 0));
end entity RAM32x32;

architecture dataflow of RAM32x32 is
type rom_array is array (0 to 31) of std_logic_vector (31 downto 0);
signal rom_data: rom_array := (x"00000000", x"00003ABA", x"00002296",x"000000AA",
x"00001C3A",x"00001180", x"000022E0",x"00001C86",x"000022DA",x"00000414",x"00001A32",
x"00000102", x"00001CBA",x"00000CDE", x"00003994",x"00001984", x"000028C4",
x"00002E7C", x"00003966",x"0000227E", x"00002208",x"000011B4", x"0000237C",
x"0000360E",x"00002722", x"00000500", x"000016B6",x"0000029E",x"00002280",
x"00002B52", x"000011A0",x"00000000");
begin 
	process(clk)
begin
	if(rising_edge(clk)) then
	if(enable = '1') then 	   
		output1 <= rom_data(conv_integer(Address1));
		output2 <= rom_data(conv_integer(Address2));
		rom_data(conv_integer(Address3)) <= input;	
end if;
end if;
end process;
end architecture dataflow;
--**************************************************************************************************************
--                                                   Enable  
--**************************************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 
use IEEE.std_logic_signed.all;

entity my_Enable is
    port(opcode : in std_logic_vector(5 downto 0);
         enable : out std_logic );
end my_Enable;

architecture arch of my_Enable is
begin
    process(opcode)
	begin 
        case opcode is
			when "001000" => enable <= '1';
			when "001001" => enable <= '1';
			when "000010" => enable <= '1';
			when "001010" => enable <= '1';
			when "001100" => enable <= '1';
			when "000001" => enable <= '1';
			when "001101" => enable <= '1'; 
			when "000101" => enable <= '1';
			when "000100" => enable <= '1';
			when "001011" => enable <= '1';
			when "001111" => enable <= '1';
		    when others   => enable <= '0';
        end case;
    end process;
end arch;
--**************************************************************************************************************
--                                                32 BIT register  
--**************************************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bit_register is
port (Machine_instructions :in std_logic_vector (31 downto 0);
clk : in  std_logic ;
Address1, Address2 ,Address3: out std_logic_vector (4 downto 0);
opcode: out std_logic_vector(5 downto 0));
end entity bit_register;

architecture data of bit_register is
begin 
	process(clk)
begin
	if(rising_edge(clk)) then 
	opcode  (5 downto 0) <= Machine_instructions(31 downto 26) ;   --6 bit
	Address1(4 downto 0) <= Machine_instructions(25 downto 21) ;   --5 bit
	Address2(4 downto 0) <= Machine_instructions(20 downto 16) ;   --5 bit
	Address3(4 downto 0) <= Machine_instructions(15 downto 11 );   --5 bit
end if;	
end process;
end architecture data;
--**************************************************************************************************************
--                                                design  
--**************************************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity project is
port (instructions :in std_logic_vector (31 downto 0);
clk : in  std_logic;
r ,out1 ,out2: out std_logic_vector (31 downto 0);
A11 ,A22 ,A33 : out std_logic_vector (4 downto 0);
opcuode : out std_logic_vector(5 downto 0);
enable :out std_logic );
end entity project;	

architecture design of project is
signal A1 ,A2 ,A3 :std_logic_vector (4 downto 0);
signal opc :std_logic_vector(5 downto 0);
signal en :std_logic;
signal ram_out1,ram_out2 ,Result : std_logic_vector (31 downto 0);
begin 
	
	r    <= Result;
	A11  <= A1;
	A22  <= A2;
	A33  <= A3;
	out1 <= ram_out1;
	out2 <= ram_out1;
	opcuode <= opc;
	enable <= en;	
	
	enablee : entity work.my_Enable(arch) port map(opc,en);
	reg : entity work.bit_register(data) port map (instructions,clk,A1,A2,A3,opc);
	alu : entity work.alu(dataopcode)    port map(ram_out1,ram_out2,opc,Result);	
	ram : entity work.RAM32x32(dataflow) port map(A1,A2,A3,en,Result,clk,ram_out1,ram_out2);
end architecture design;
--**************************************************************************************************************
--                                               test bench  
--**************************************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_test is
end entity alu_test;

architecture test of alu_test is
signal instructions : std_logic_vector (31 downto 0);
signal clk : std_logic := '0';
signal A1 ,A2 ,A3 :std_logic_vector (4 downto 0) := (others => '0');
signal opc :std_logic_vector(5 downto 0) := (others => '0');
signal en :std_logic := '0';
signal ram_out1,ram_out2 ,Result : std_logic_vector (31 downto 0) := (others => '0');
begin
system : entity work.project(design) port map(instructions,clk,Result,ram_out1,ram_out1,A1,A2,A3,opc,en);
clk <= not clk after 75 ns;
instructions <=
"00000100001000100000000000000000" ,
"00000100000000110000000000000000"  after 400  ns ,  
"00000100000001000000000000000000"  after 800  ns ,
"00000100000001010000000000000000"  after 1200 ns ,
"00000100000001100000000000000000"  after 1600 ns ,
"00000100000001110000000000000000"  after 2000 ns ,
"00000100000010000000000000000000"  after 2400 ns ,
"00000100000010010000000000000000"  after 2800 ns ,
"00000100000010100000000000000000"  after 3200 ns ,
"00000100000010110000000000000000"  after 3600 ns ,
"00000100000011000000000000000000"  after 4000 ns ,
"00000100000011010000000000000000"  after 4400 ns ,
"00000100000011100000000000000000"  after 4800 ns ,
"00000100000011110000000000000000"  after 5200 ns ,
"00000100000100000000000000000000"  after 5600 ns ,
"00000100000100010000000000000000"  after 6000 ns ,
"00000100000100100000000000000000"  after 6400 ns ,
"00000100000100110000000000000000"  after 6800 ns ,
"00000100000101000000000000000000"  after 7200 ns ,
"00000100000101010000000000000000"  after 7600 ns ,
"00000100000101100000000000000000"  after 8000 ns ,
"00000100000101110000000000000000"  after 8400 ns ,
"00000100000110000000000000000000"  after 8600 ns ,
"00000100000110010000000000000000"  after 9000 ns ,
"00000100000110100000000000000000"  after 9400 ns ,
"00000100000110110000000000000000"  after 9800 ns ,
"00000100000111000000000000000000"  after 10200 ns,
"00000100000111010000000000000000"  after 10600 ns,
"00000100000111100000000000000000"  after 11000 ns,
"00000100000000100000000000000000"  after 11400 ns;
end architecture test;
 