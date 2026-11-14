library ieee;
use ieee.std_logic_1164.all;

-- Board interface only: input storage does not belong to the CLU datapath.
-- C5G pushbuttons are active-low and are hardware debounced on the board.
entity clu_c5g_top is
    port (
        CLOCK_50 : in std_logic;
        SW : in std_logic_vector(9 downto 0);
        KEY : in std_logic_vector(3 downto 0);
        LEDR : out std_logic_vector(9 downto 0);
        LEDG : out std_logic_vector(7 downto 0);
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of clu_c5g_top is
    signal reset_pipe : std_logic_vector(1 downto 0) := "00";
    signal sw_meta, sw_sync : std_logic_vector(9 downto 0) := (others => '0');
    signal key_meta, key_sync, key_prev : std_logic_vector(2 downto 0) := "111";
    signal a_reg, b_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal op_reg : std_logic_vector(2 downto 0) := "000";
    signal result_bus, display_bus : std_logic_vector(7 downto 0);
    signal z_flag, c_flag, n_flag, lt_flag : std_logic;
    attribute altera_attribute : string;
    attribute altera_attribute of sw_meta, key_meta : signal is
        "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS";
begin
    -- Asynchronous reset assertion, synchronous release.
    process(CLOCK_50, KEY(3))
    begin
        if KEY(3) = '0' then reset_pipe <= "00";
        elsif rising_edge(CLOCK_50) then reset_pipe <= reset_pipe(0) & '1';
        end if;
    end process;

    process(CLOCK_50, reset_pipe(1))
    begin
        if reset_pipe(1) = '0' then
            sw_meta <= (others => '0'); sw_sync <= (others => '0');
            key_meta <= "111"; key_sync <= "111"; key_prev <= "111";
            a_reg <= (others => '0'); b_reg <= (others => '0'); op_reg <= "000";
        elsif rising_edge(CLOCK_50) then
            sw_meta <= SW; sw_sync <= sw_meta;
            key_meta <= KEY(2 downto 0); key_sync <= key_meta; key_prev <= key_sync;
            if key_prev(0) = '1' and key_sync(0) = '0' then a_reg <= sw_sync(7 downto 0); end if;
            if key_prev(1) = '1' and key_sync(1) = '0' then b_reg <= sw_sync(7 downto 0); end if;
            if key_prev(2) = '1' and key_sync(2) = '0' then op_reg <= sw_sync(2 downto 0); end if;
        end if;
    end process;

    unit_under_test : entity work.clu
        port map (a => a_reg, b => b_reg, op => op_reg, r => result_bus,
                  z => z_flag, c => c_flag, n => n_flag, lt => lt_flag);

    LEDR <= "00" & result_bus;
    LEDG <= '1' & op_reg & lt_flag & n_flag & c_flag & z_flag;

    with sw_sync(9 downto 8) select display_bus <=
        a_reg when "00", b_reg when "01", sw_sync(7 downto 0) when "10",
        "00000" & op_reg when others;

    result_lo : entity work.hex7seg port map(result_bus(3 downto 0), HEX0);
    result_hi : entity work.hex7seg port map(result_bus(7 downto 4), HEX1);
    input_lo  : entity work.hex7seg port map(display_bus(3 downto 0), HEX2);
    input_hi  : entity work.hex7seg port map(display_bus(7 downto 4), HEX3);
end architecture;
