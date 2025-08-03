library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity inverter is
  generic (
    data_width : integer := 32
  );
  Port (
    clk          : in  std_logic;
    reset        : in  std_logic;  -- synchronous active-high reset
    -- AXI slave interface
    s_axis_data  : in  std_logic_vector(data_width - 1 downto 0);
    s_axis_valid : in  std_logic;
    s_axis_ready : out std_logic;

    -- AXI master interface
    m_axis_data  : out std_logic_vector(data_width - 1 downto 0);
    m_axis_valid : out std_logic;
    m_axis_ready : in  std_logic
  );
end inverter;

architecture Behavioral of inverter is

  signal valid_reg : std_logic := '0';
  signal data_reg  : std_logic_vector(data_width - 1 downto 0) := (others => '0');

begin

  -- Ready: accept new data if buffer is empty or downstream accepted previous data
  s_axis_ready <= not valid_reg or  m_axis_ready;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then  -- synchronous reset
        valid_reg <= '0';
        data_reg  <= (others => '0');
      else
        -- Clear valid_reg when downstream accepts data
        if valid_reg = '1' and m_axis_ready = '1' then
          valid_reg <= '0';
        end if;

        -- Latch new data when upstream valid & ready
        if s_axis_valid = '1' and s_axis_ready = '1' then
          valid_reg <= '1';
          -- Invert each byte: 255 - input_byte
          for i in 0 to (data_width/8) - 1 loop
            data_reg((i*8+7) downto i*8) <= std_logic_vector(
              to_unsigned(255 - to_integer(unsigned(s_axis_data((i*8+7) downto i*8))), 8));
          end loop;
        end if;
      end if;
    end if;
  end process;

  -- Output assignments outside process
  m_axis_valid <= valid_reg;
  m_axis_data  <= data_reg;

end Behavioral;
