# Copyright (C) 2011-2012 Kenichi Kamiya

require 'ipaddr'
require_relative '../parsertemplate'
require_relative 'topology'

module NetworkNodeManager

  module OvTopoDump_rRISC

    extend Parsable
    
    class << self
      
      alias_method :load_nodes, :load
    
    end

    class Parser < ParserTemplate

      include Topology

      def parse_nodes
        trim_header
        nodes = _parse_nodes
        trim_blank
        trim_eos
        eos? ? nodes : error('rest is.')
      end
      
      alias_method :parse, :parse_nodes
      
      private
      
      def _parse_nodes
        [].tap {|nodes|
          while scan(%r~^ *([1-9]\d*) +(-|IP) +([!#&@*])?(\S+) +([A-Z][a-z]+) +(-|[\d.]+) +(\S+)\n~)
            node = Node.load_pairs id: Integer(@s[1]), hostname: @s[4], interfaces: []

            unless @s[6] == '-'
              ipaddr = IPAddr.new @s[6]
            end

            while interface = parse_interface
              node.interfaces << interface
            end

            if m_int = node.interfaces.find{|int|int.ipaddress == ipaddr}
              node.main_interface = m_int
            end

            nodes << node.lock
          end
        }
      end
      
      def trim_header
        scan_until(/^NODES:\n/)
      end

      def parse_interface
        if scan(%r~^ *([1-9]\d*)/([1-9]\d*) +(-|IP) +([!#&@*])?(\S+) +([A-Z][a-z]+) +(\-|[\d.]+) +(\S+)\n?~)
          Interface.define do |int|
            int.id = Integer @s[2]
            int.flag = (@s[4] && @s[4].to_sym)
  
            if /\A[\d.]+\z/ =~ @s[7]
              int.ipaddress = IPAddr.new @s[7]
            else
              if @s[3] == 'IP'
                error
              else
                int.ipaddress = nil
              end
            end
          
            int.status = @s[6].to_sym
          end
        end
      end
  
    end

  end

end