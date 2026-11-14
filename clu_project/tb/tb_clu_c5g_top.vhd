library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clu_c5g_top is end entity;

architecture test of tb_clu_c5g_top is
    signal clk : std_logic := '0';
    signal sw : std_logic_vector(9 downto 0) := (others => '0');
    signal key : std_logic_vector(3 downto 0) := "1111";
    signal ledr : std_logic_vector(9 downto 0);
    signal ledg : std_logic_vector(7 downto 0);
    signal h0,h1,h2,h3 : std_logic_vector(6 downto 0);
    signal done : boolean := false;
    type segment_table is array (0 to 15) of std_logic_vector(6 downto 0);
    constant patterns : segment_table :=
        ("1000000","1111001","0100100","0110000",
         "0011001","0010010","0000010","1111000",
         "0000000","0010000","0001000","0000011",
         "1000110","0100001","0000110","0001110");
    function flag(condition : boolean) return std_logic is
    begin
        if condition then return '1'; else return '0'; end if;
    end function;
begin
    clk <= not clk after 10 ns when not done else '0';
    dut : entity work.clu_c5g_top port map(clk,sw,key,ledr,ledg,h0,h1,h2,h3);
    stimulus : process
        procedure switches(value : natural) is
        begin
            sw <= std_logic_vector(to_unsigned(value,10)); wait for 160 ns;
        end procedure;
        procedure press(index : natural) is
        begin
            key(index) <= '0'; wait for 160 ns;
            key(index) <= '1'; wait for 160 ns;
        end procedure;
        procedure result_is(value : natural; flags : std_logic_vector(3 downto 0)) is
        begin
            assert ledr = "00" & std_logic_vector(to_unsigned(value,8))
                report "Board result mismatch" severity failure;
            -- flags order: LT N C Z, as LEDG(3 downto 0).
            assert ledg(3 downto 0) = flags report "Board flags mismatch" severity failure;
            assert h0 = patterns(value mod 16) and h1 = patterns(value / 16)
                report "Result display mismatch" severity failure;
        end procedure;
        procedure display_is(value : natural) is
        begin
            assert h2 = patterns(value mod 16) and h3 = patterns(value / 16)
                report "Input display mismatch" severity failure;
        end procedure;
    begin
        press(3);
        result_is(0,"0001"); display_is(0);
        assert ledg(7) = '1' severity failure;

        -- Walking patterns verify each switch/data bit and all hexadecimal digits.
        for value in 0 to 255 loop
            switches(value); press(0);
            result_is(value,"0" & flag(value >= 128) & '0' & flag(value = 0));
            display_is(value);
        end loop;

        -- FF + 01 -> 00, carry; changing switches alone must not change A/B/OP.
        switches(1); press(1); result_is(0,"0011");
        switches(16#AA#); result_is(0,"0011");
        switches(256); display_is(1);
        switches(512 + 16#AB#); display_is(16#AB#);
        switches(768); display_is(0);

        -- Load 03,05, subtraction; ensure OP changes only when KEY2 is pressed.
        switches(3); press(0); switches(5); press(1); result_is(8,"1000");
        switches(1); press(2); result_is(254,"1110");
        assert ledg(6 downto 4) = "001" severity failure;
        switches(768); display_is(1);
        switches(5); press(2); result_is(1,"1000");
        switches(6); press(2); result_is(0,"1001");
        switches(7); press(2); result_is(96,"1000");

        -- A held button captures once, even if the switch data then changes.
        switches(10); key(0) <= '0'; wait for 160 ns;
        switches(20); key(0) <= '1'; wait for 160 ns;
        switches(0); press(2); result_is(15,"0000"); display_is(10);
        press(3); result_is(0,"0001"); display_is(0);
        report "PASS: C5G interface reset, loads, hold behavior, all 256 data values, display pages and flags" severity note;
        done <= true;
        wait;
    end process;
end architecture;
