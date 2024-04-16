----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.04.2024 15:45:08
-- Design Name: 
-- Module Name: inverter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity inverter is
  generic (
        DATA_WIDTH : integer := 32
  );
  Port (
        clk : in std_logic;
        rst : in std_logic;
        -- axi 4 slave
        s_valid : in std_logic;
        s_ready : out std_logic;
        s_data : in std_logic_vector (DATA_WIDTH -1 downto 0); 
        -- axi 4 master
        m_valid : out std_logic;
        m_ready : in std_logic;
        m_data : out std_logic_vector (DATA_WIDTH -1 downto 0)
        
        );
end inverter;

architecture Behavioral of inverter is

begin

    s_ready <= m_ready;
    
    process (clk) begin
        if rising_edge (clk) then
            if rst = '1' then
                m_data <= (others => '0');
            else
              if (s_valid = '1' and m_ready = '1') then
                for i in 0 to DATA_WIDTH/8 -1 loop
                    m_data (i*8+7 downto i*8) <= std_logic_vector (to_unsigned(255, 8) - unsigned(s_data(i*8+7 downto i*8)));
                end loop;
              end if;
            end if;
        end if ;
    end process;
    
    process (clk) begin
        if rising_edge (clk) then
            if rst = '1' then
                m_valid <= '0';
            else
                m_valid <= s_valid;
            end if;
        end if;
    end process;

end Behavioral;
