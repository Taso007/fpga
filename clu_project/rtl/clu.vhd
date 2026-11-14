library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Purely combinational 8-bit CLU. There is deliberately no clock port.
entity clu is
    port (
        a, b : in  std_logic_vector(7 downto 0);
        op   : in  std_logic_vector(2 downto 0);
        r    : out std_logic_vector(7 downto 0);
        z, c, n, lt : out std_logic
    );
end entity;

architecture rtl of clu is
begin
    process(all)
        variable result_v : std_logic_vector(7 downto 0);
        variable sum_v    : unsigned(8 downto 0);
        variable carry_v  : std_logic;
        variable pa, pb   : std_logic;
    begin
        -- Defaults on every evaluation prevent inferred latches.
        result_v := (others => '0');
        sum_v := (others => '0');
        carry_v := '0';
        pa := '0';
        pb := '0';

        case op is
            when "000" =>
                sum_v := ('0' & unsigned(a)) + ('0' & unsigned(b));
                result_v := std_logic_vector(sum_v(7 downto 0));
                carry_v := sum_v(8);
            when "001" =>
                result_v := std_logic_vector(unsigned(a) - unsigned(b));
                -- Convention: C=1 means a borrow occurred on subtraction.
                if unsigned(a) < unsigned(b) then carry_v := '1'; end if;
            when "010" => result_v := a and b;
            when "011" => result_v := a or b;
            when "100" => result_v := a xor b;
            when "101" =>
                -- R(2)=A>B, R(1)=A=B, R(0)=A<B; R(7:3)=0.
                if unsigned(a) > unsigned(b) then result_v(2) := '1';
                elsif a = b then result_v(1) := '1';
                else result_v(0) := '1';
                end if;
            when "110" =>
                -- Even-parity bits: append R(0) to A, R(1) to B.
                for i in 0 to 7 loop
                    pa := pa xor a(i);
                    pb := pb xor b(i);
                end loop;
                result_v(0) := pa;
                result_v(1) := pb;
            when "111" =>
                -- Custom operation: rotate A left by B(2 downto 0), 0..7.
                result_v := std_logic_vector(rotate_left(unsigned(a),
                                            to_integer(unsigned(b(2 downto 0)))));
            when others => null;
        end case;

        r <= result_v;
        c <= carry_v;
        n <= result_v(7);
        if result_v = x"00" then z <= '1'; else z <= '0'; end if;
        if unsigned(a) < unsigned(b) then lt <= '1'; else lt <= '0'; end if;
    end process;
end architecture;
