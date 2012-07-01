# Copyright (C) 2011-2012 Kenichi Kamiya

require 'ipaddr'
require 'striuct'

module NetworkNodeManager

  module Topology

    Interface = Striuct.define do
      member :id, Integer
      member :ipaddress, OR(IPAddr, nil)
      alias_member :ipaddr, :ipaddress
      member :status, MEMBER_OF([
        :Critical,
        :Disabled,
        :Major,
        :Marginal,
        :Normal,
        :Unknown,
        :Unmanaged,
        :Warning
      ].freeze)

      member :flag, OR(nil, MEMBER_OF(%w[! # & @ *].map(&:to_sym).freeze))

      def enable?
        ! status.equal?(:Unmanaged)
      end
      
      def ovvalid?
        flag.nil? && enable?
      end
    end
  
    Node = Striuct.define do
      member :id, Integer
      member :hostname, STRINGABLE? do |v|
        v.to_s
      end
      
      member :interfaces, GENERICS(Interface)
      member :main_interface, ->v{interfaces.include? v}
      
      def ipaddress
        main_interface && main_interface.ipaddress
      end
      
      alias_method :ipaddr, :ipaddress
      
      def relative?(interface)
        interfaces.any?{|int|int == interface}
      end
    end

  end
end