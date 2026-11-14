library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clu is
    generic (EXHAUSTIVE : boolean := false);
end entity;

architecture test of tb_clu is
    signal a, b, r : std_logic_vector(7 downto 0) := (others => '0');
    signal op : std_logic_vector(2 downto 0) := "000";
    signal z, c, n, lt : std_logic;
    signal done : boolean := false;

    function bit_value(condition : boolean) return std_logic is
    begin
        if condition then return '1'; else return '0'; end if;
    end function;

    function odd_ones(value : natural) return natural is
        variable remaining : natural := value;
        variable parity : natural := 0;
    begin
        for i in 0 to 7 loop
            parity := (parity + remaining mod 2) mod 2;
            remaining := remaining / 2;
        end loop;
        return parity;
    end function;
begin
    dut : entity work.clu port map(a, b, op, r, z, c, n, lt);

    stimulus : process
        variable count : natural := 0;
        procedure check(av, bv, opcode : natural) is
            variable expected_r, shifted, shift_count : natural;
            variable expected_c : std_logic := '0';
            variable weight, abit, bbit : natural;
        begin
            expected_r := 0;
            expected_c := '0';
            -- Integer reference model; it does not call the DUT's helpers.
            case opcode is
                when 0 =>
                    expected_r := (av + bv) mod 256;
                    expected_c := bit_value(av + bv > 255);
                when 1 =>
                    expected_r := (av + 256 - bv) mod 256;
                    expected_c := bit_value(av < bv);
                when 2 | 3 | 4 =>
                    for i in 0 to 7 loop
                        weight := 2**i;
                        abit := (av / weight) mod 2;
                        bbit := (bv / weight) mod 2;
                        if (opcode = 2 and abit = 1 and bbit = 1) or
                           (opcode = 3 and (abit = 1 or bbit = 1)) or
                           (opcode = 4 and abit /= bbit) then
                            expected_r := expected_r + weight;
                        end if;
                    end loop;
                when 5 =>
                    if av > bv then expected_r := 4;
                    elsif av = bv then expected_r := 2;
                    else expected_r := 1; end if;
                when 6 => expected_r := odd_ones(av) + 2 * odd_ones(bv);
                when 7 =>
                    shift_count := bv mod 8;
                    shifted := av * 2**shift_count;
                    expected_r := (shifted mod 256) + shifted / 256;
                when others => assert false severity failure;
            end case;
            a <= std_logic_vector(to_unsigned(av, 8));
            b <= std_logic_vector(to_unsigned(bv, 8));
            op <= std_logic_vector(to_unsigned(opcode, 3));
            wait for 10 ns;
            assert r = std_logic_vector(to_unsigned(expected_r, 8))
                report "R mismatch OP=" & integer'image(opcode) &
                       " A=" & integer'image(av) & " B=" & integer'image(bv) &
                       " expected=" & integer'image(expected_r) severity failure;
            assert z = bit_value(expected_r = 0) report "Z mismatch" severity failure;
            assert c = expected_c report "C mismatch" severity failure;
            assert n = bit_value(expected_r >= 128) report "N mismatch" severity failure;
            assert lt = bit_value(av < bv) report "LT mismatch" severity failure;
            count := count + 1;
        end procedure;
    begin
        -- Clear, short waveform sequence with every operation and key edges.
        check(0,0,0); check(5,3,0); check(255,1,0); check(255,255,0);
        check(0,0,1); check(5,3,1); check(3,5,1); check(0,1,1); check(255,255,1);
        check(16#AA#,16#55#,2); check(16#F0#,16#CC#,2);
        check(16#AA#,16#55#,3); check(0,0,3);
        check(16#AA#,16#55#,4); check(255,255,4);
        check(5,3,5); check(5,5,5); check(3,5,5);
        check(0,0,6); check(1,0,6); check(0,1,6); check(1,1,6); check(255,255,6);
        check(16#81#,0,7); check(16#81#,1,7); check(16#81#,7,7); check(16#81#,9,7);
        if EXHAUSTIVE then
            for opcode in 0 to 7 loop
                for av in 0 to 255 loop
                    for bv in 0 to 255 loop check(av,bv,opcode); end loop;
                end loop;
            end loop;
        end if;
        report "PASS: CLU checked " & integer'image(count) & " vectors, R/Z/C/N/LT all correct" severity note;
        done <= true;
        wait;
    end process;
end architecture;
