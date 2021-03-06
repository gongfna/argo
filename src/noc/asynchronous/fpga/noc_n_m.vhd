--
-- Copyright Technical University of Denmark. All rights reserved.
-- This file is part of the T-CREST project.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
--
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
--


--------------------------------------------------------------------------------
-- NxN bi-torus NoC.
--
-- Author: Evangelia Kasapaki
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.config_types.all;
use work.config.all;
use work.noc_defs.all;
use work.noc_interface.all;
use work.ocp.all;


entity noc is

port (
	p_clk		: in std_logic;
	n_clk		: in std_logic;
       	n_clk_skd	: in std_logic;

	reset		: in std_logic;

	p_ports_in	: in ocp_io_m_a;
	p_ports_out	: out ocp_io_s_a;

	spm_ports_in	: in spm_slaves;
	spm_ports_out	: out spm_masters

);

end noc;

architecture struct of noc is

------------------------------component declarations----------------------------

component self_timed_noc_2x2 is
port (
	reset		: in std_logic;

    -- router ports
   	n00_in_f		 : in channel_forward;
	n00_in_b		 : out channel_backward;
	n01_in_f	     : in channel_forward;
	n01_in_b	     : out channel_backward;
	n10_in_f		 : in channel_forward;
	n10_in_b		 : out channel_backward;
	n11_in_f	     : in channel_forward;
	n11_in_b	     : out channel_backward;

	-- Output ports
	n00_out_f		 : out channel_forward;
	n00_out_b		 : in channel_backward;
	n01_out_f		 : out channel_forward;
	n01_out_b		 : in channel_backward;
	n10_out_f		 : out channel_forward;
	n10_out_b		 : in channel_backward;
	n11_out_f		 : out channel_forward;
	n11_out_b		 : in channel_backward

);

end component;

------------------------------signal declarations----------------------------
type clk_n is array (0 to (N-1)) of std_logic;
type clk_m is array (0 to (M-1)) of clk_n;

type links_n is array (0 to (N-1)) of link_t;
type links_m is array (0 to (M-1)) of links_n;

type link_n_f is array(0 to (N - 1)) of channel_forward;
type link_n_b is array(0 to (N - 1)) of channel_backward;
type link_m_f is array(0 to (M - 1)) of link_n_f;
type link_m_b is array(0 to (M - 1)) of link_n_b;

signal ip_to_net_link	: links_m;
signal net_to_ip_link   : links_m;

signal half_clk         : clk_m := (others => (others => '0'));
signal del_half_clk0    : clk_m;

signal ip_to_net_f : link_m_f;
signal ip_to_net_b : link_m_b;
signal net_to_ip_f : link_m_f;
signal net_to_ip_b : link_m_b;


begin
	routers: self_timed_noc_2x2 port map(
		reset => reset,
	   	n00_in_f => ip_to_net_f(0)(0),
		n00_in_b => ip_to_net_b(0)(0),
		n01_in_f => ip_to_net_f(0)(1),
		n01_in_b => ip_to_net_b(0)(1),
		n10_in_f => ip_to_net_f(1)(0),
		n10_in_b => ip_to_net_b(1)(0),
		n11_in_f => ip_to_net_f(1)(1),
		n11_in_b => ip_to_net_b(1)(1),
		n00_out_f => net_to_ip_f(0)(0),
		n00_out_b => net_to_ip_b(0)(0),
		n01_out_f => net_to_ip_f(0)(1),
		n01_out_b => net_to_ip_b(0)(1),
		n10_out_f => net_to_ip_f(1)(0),
		n10_out_b => net_to_ip_b(1)(0),
		n11_out_f => net_to_ip_f(1)(1),
		n11_out_b => net_to_ip_b(1)(1)
	);

	nodes_m : for i in 0 to M-1 generate
		nodes_n : for j in 0 to N-1 generate
                        skewed: if i=0 and j=0 generate
                        	half_clk_gen: process (n_clk_skd, reset)
				begin
					if reset='1' then
					  half_clk(i)(j) <= '0';
					elsif falling_edge(n_clk_skd) then
					      half_clk(i)(j) <= not half_clk(i)(j);
					end if;
				end process half_clk_gen;
				del_half_clk0(i)(j) <= not half_clk(i)(j);
				ip_to_net_f(i)(j).req <= not del_half_clk0(i)(j) after 2 ns;
				ip_to_net_f(i)(j).data <= ip_to_net_link(i)(j);
				net_to_ip_link(i)(j) <= net_to_ip_f(i)(j).data;
				net_to_ip_b(i)(j).ack <= not del_half_clk0(i)(j) after 2 ns;
                        
		                -- NA instance
				na : entity work.nAdapter
				port map(
					-- General
					na_clk=>n_clk_skd,
					na_reset=>reset,

					-- Processor Ports
					-- DMA Configuration Port - OCP
					proc_in=>p_ports_in((i*N)+j),
					proc_out=>p_ports_out((i*N)+j),

					-- SPM Data Port - OCP?
					spm_in=>spm_ports_in((i*N)+j),
					spm_out=>spm_ports_out((i*N)+j),

					-- Network Ports
					-- Incoming Port
					pkt_in=>net_to_ip_link(i)(j),

					-- Outgoing Port
					pkt_out=>ip_to_net_link(i)(j)
				);
				
			end generate skewed;			

		    	not_skewed: if not(i=0) or not(j=0) generate
		    	
		    		half_clk_gen: process (n_clk, reset)
				begin
					if reset='1' then
					  half_clk(i)(j) <= '0';
					elsif falling_edge(n_clk) then
					      half_clk(i)(j) <= not half_clk(i)(j);
					end if;
				end process half_clk_gen;
				del_half_clk0(i)(j) <= not half_clk(i)(j);
				ip_to_net_f(i)(j).req <= not del_half_clk0(i)(j) after 2 ns;
				ip_to_net_f(i)(j).data <= ip_to_net_link(i)(j);
				net_to_ip_link(i)(j) <= net_to_ip_f(i)(j).data;
				net_to_ip_b(i)(j).ack <= not del_half_clk0(i)(j) after 2 ns;

				-- NA instance
				na : entity work.nAdapter
				port map(
					-- General
					na_clk=>n_clk,
					na_reset=>reset,

					-- Processor Ports
					-- DMA Configuration Port - OCP
					proc_in=>p_ports_in((i*N)+j),
					proc_out=>p_ports_out((i*N)+j),

					-- SPM Data Port - OCP?
					spm_in=>spm_ports_in((i*N)+j),
					spm_out=>spm_ports_out((i*N)+j),

					-- Network Ports
					-- Incoming Port
					pkt_in=>net_to_ip_link(i)(j),

					-- Outgoing Port
					pkt_out=>ip_to_net_link(i)(j)
				);


                        end generate not_skewed;


		end generate nodes_n;
	end generate nodes_m;
	
end struct;
