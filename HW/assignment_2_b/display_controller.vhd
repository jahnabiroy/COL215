
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity display_controller is
    --  Port ( );
end display_controller;

architecture Behavioral of display_controller is
    COMPONENT dist_mem_gen_0 ---rom image
        PORT (
            a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC);
    END COMPONENT;

    COMPONENT dist_mem_gen_1      --rom filter
        PORT (
            a : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC);
    END COMPONENT;

    COMPONENT dist_mem_gen_2      --ram
        PORT (
            a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;

    -- STORE THE VALUES IN THE KERNEL
    SHARED VARIABLE PK11: integer := 0;
    SHARED VARIABLE PK21: integer := 0;
    SHARED VARIABLE PK31: integer := 0;
    SHARED VARIABLE QK11: integer := 0;
    SHARED VARIABLE QK21: integer := 0;
    SHARED VARIABLE QK31: integer := 0;
    SHARED VARIABLE RK11: integer := 0;
    SHARED VARIABLE RK21: integer := 0;
    SHARED VARIABLE RK31: integer := 0;
   

    SIGNAL ROMADDRESS : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ROMOUTPUT : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL RAMADDRESS : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RAMINPUT : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WRITE_ENABLE : STD_LOGIC := '1';
    SIGNAL RAMOUTPUT : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL K_ROMADDRESS: STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL K_ROM: STD_LOGIC_VECTOR(7 DOWNTO 0):= (OTHERS => '0');

    constant clock_period : time := 10ns;
    constant clock_period2: time := 5ps;
    signal PIXEL_COUNT:INTEGER:=-1;
    signal clk2 : std_logic := '1';
    signal clk : std_logic := '1';
    signal  flag : integer := 0;--TO DECIDE TO READ KERNEL
    signal new_flag:integer:=0;--to see when to calculate the min and max and when to normalise
    SIGNAL FINAL_OUTPUT:INTEGER:=0;--TO BE REMOVED
 

    signal i : integer := 0;
    signal j : integer := -1;
    
    signal mmax : integer := 0;
    signal mmin : integer := 0;
    
    signal CHECKER:INTEGER:=0;

begin

    rom : dist_mem_gen_0 PORT MAP(
            a => ROMADDRESS,
            clk => clk,
            spo => ROMOUTPUT);

    krom : dist_mem_gen_1 PORT MAP(
            a => K_ROMADDRESS,
            clk => clk,
            spo => K_ROM);

    ram : dist_mem_gen_2 PORT MAP(
            a => RAMADDRESS,
            d => RAMINPUT,
            clk => clk,
            we => WRITE_ENABLE,
            spo => RAMOUTPUT);

    clock_process :process
    begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;

     clock_process2 :process
    begin
        clk2 <= '0';
        wait for clock_period2/2;
        clk2 <= '1';
        wait for clock_period2/2;
    end process;
    -- PROCESS TO READ THE KERNEL
    read_kernel : process(clk)
        variable c: integer := 0;
    begin
        IF FLAG=0 THEN
            if rising_edge(clk) then
                if c = 0 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(1,4));
                    c := 1;
                elsif c = 1 then
                    pk11 := to_integer(signed(K_ROM));
                    c := 2;
                elsif c = 2 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(2,4));
                    c := 3;
                elsif c = 3 then
                    pk21 := to_integer(signed(K_ROM));
                    c := 4;
                elsif c = 4 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(3,4));
                    c := 5;
                elsif c = 5 then
                    pk31 := to_integer(signed(K_ROM));
                    c := 6;
                elsif c = 6 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(4,4));
                    c := 7;
                elsif c = 7 then
                    qk11 := to_integer(signed(K_ROM));
                    c := 8;
                elsif c = 8 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(5,4));
                    c := 9;
                elsif c = 9 then
                    qk21 := to_integer(signed(K_ROM));
                    c := 10;
                elsif c = 10 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(6,4));
                    c := 11;
                elsif c = 11 then
                    qk31 := to_integer(signed(K_ROM));
                    c := 12;
                elsif c = 12 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(7,4));
                    c := 13;
                elsif c = 13 then
                    rk11 := to_integer(signed(K_ROM));
                    c := 14;
                elsif c = 14 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(8,4));
                    c := 15;
                elsif c = 15 then
                    rk21 := to_integer(signed(K_ROM));
                    c := 16;
                elsif c = 16 then
                    K_ROMADDRESS <= std_logic_vector(to_signed(9,4));
                    c := 17;
                elsif c = 17 then
                    rk31 := to_integer(signed(K_ROM));
                    FLAG<=1;
                end if;
            END IF;
        end if;
    end process;

    
    --PROCESS TO PASS THE VALUE OF RAM ADDRESS TO WRITE      
    RAM_ADDRESS_ASSIGN : PROCESS (clk2)

    BEGIN

        IF (rising_edge(clk2)) THEN
            IF (PIXEL_COUNT < 4096) THEN
                RAMADDRESS <= STD_LOGIC_VECTOR(TO_UNSIGNED(64 * i + j, 12));
                WRITE_ENABLE <= '1';
            ELSE
                WRITE_ENABLE <= '0';
            END IF;
        END IF;
    END PROCESS;



    IMAGE_PROCESSOR:PROCESS(CLK2)

    VARIABLE p1,p2,p3,q1,q2,q3,r1,r2,r3:integer:=0;
    VARIABLE OUTPIXEL :INTEGER:=0;
    variable min : integer := 0;
    variable max : integer := 0;
    begin
        IF FLAG = 1 then
            IF PIXEL_COUNT<4096 THEN
                IF rising_edge(CLK2) then
                    if checker=0 then
                        if j=63 then
                            i<=i+1;
                            j<=0;
                        else
                            j<=j+1;
                        end if;
                        PIXEL_COUNT <=PIXEL_COUNT+1;
                        checker<=1;

                    elsif checker=1 then
                          if i > 0 then
                            if j=0 then
                                ROMADDRESS<=std_logic_vector(to_unsigned(64*(i-1)+j,12));
                            end if;
                          end if;
                            checker<=2;
                        elsif checker=2 then
                            if j=0 then
                                p1:=0;

                            elsif i=0 then
                                p1:=0;
                            else
                                p1:=p2;
                            end if;
                            checker<=3;

                        elsif checker=3 then
                            if i=0 then
                                p2:=0;
                            elsif j=0 then
                                p2:=to_integer(unsigned(ROMOUTPUT));
                            else
                                p2:=p3;

                            end if;
                            checker<=4;

                        elsif checker=4 then
                            if i > 0 then
                                ROMADDRESS<=std_logic_vector(to_unsigned(64*(i-1)+(j+1),12));
                            end if;
                            checker<=5;

                        elsif checker=5 then
                            if j=63 then
                                p3:=0;
                            elsif i = 0 then
                                p3 := 0;
                            else
                                p3:=to_integer(unsigned(ROMOUTPUT));
                            END IF;
                            checker<=6;
                        elsif checker=6 then
                            ROMADDRESS<=std_logic_vector(to_unsigned(64*i+j,12));
                            checker<=7;

                        elsif checker=7 then
                            if j=0 then
                                q1:=0;
                            else
                                q1:=q2;
                            end if;
                            checker<=8;

                        ELSIF CHECKER = 8 THEN

                            IF j = 0 THEN
                                Q2 := to_integer(unsigned(ROMOUTPUT));
                            ELSE
                                Q2 := Q3;
                            END IF;
                            CHECKER <=9;

                        ELSIF CHECKER = 9 THEN
                            if j < 63 then 
                                ROMADDRESS <= STD_LOGIC_VECTOR(to_unsigned(64*i + j+1,12));
                            end if;
                            CHECKER <=10;

                        ELSIF CHECKER = 10 THEN
                            IF j=63 THEN
                                Q3 :=0;
                            ELSE
                                Q3 := to_integer(unsigned(ROMOUTPUT));
                            END IF;
                            CHECKER <=11;

                        ELSIF CHECKER = 11 THEN
                        if i < 63 then
                            IF j = 0 THEN
                                ROMADDRESS <= STD_LOGIC_VECTOR(to_unsigned(64 *(i+1) + j, 12));
                            END IF;
                            end if;
                            CHECKER <= 12;

                        ELSIF CHECKER = 12 THEN
                            IF j = 0 THEN
                                R1 := 0;
                            elsif i=63 then
                                r1:=0;
                            ELSE
                                R1 := R2;
                            END	IF;
                            CHECKER <= 13;

                        ELSIF CHECKER = 13 THEN
                            IF i=63 THEN
                                R2 := 0;
                            ELSIF j = 0 THEN
                                R2 := to_integer(unsigned(ROMOUTPUT));
                            ELSE
                                R2 := R3;
                            END IF;
                            CHECKER <=14;

                        ELSIF CHECKER = 14 THEN
                        if i < 63 then 
                            if j < 63 then
                            ROMADDRESS <= STD_LOGIC_VECTOR(to_unsigned(64 *(i+1) + j+1,12));
                            end if;
                            end if;
                            CHECKER <=15;

                        ELSIF CHECKER = 15 THEN
                            IF j=63 THEN
                                R3 :=0;
                            elsif i=63 then
                                r3 := 0;
                            ELSE
                                R3 := to_integer(unsigned(ROMOUTPUT));
                            END IF;
                            CHECKER <=16;
                        elsif checker=16 then
                            outpixel:=pk11*p1+pk21*p2+pk31*p3+qk11*q1+qk21*q2+qk31*q3+rk11*r1+rk21*r2+rk31*r3;
--                            FINAL_OUTPUT<=OUTPIXEL;
                            if new_flag=0 then 
                                if max < outpixel then
                                    max := outpixel;
                                    mmax <= max;
                                end if;
                                if min > outpixel then 
                                    min := outpixel;
                                    mmin <= min;
                                end if;
                             end if;
                            checker <= 17;
                            
                       elsif checker = 17 then
                             if new_flag=1 then
                                ---normalize 
                                OUTPIXEL := ((outpixel - min) * 255)/(max-min);
                                RAMINPUT <= std_logic_vector(to_unsigned(OUTPIXEL,8));
                              end if;
                              
                            checker<=0;
                            
                        end if;
                END IF;
            else
                if new_flag = 0 then
                    checker<=0;
                    pixel_count<=0;
                    i<=0;
                    j<=-1;
                    new_flag <= 1;
                    end if;
            END IF;
        END IF;
    END PROCESS;

end Behavioral;
