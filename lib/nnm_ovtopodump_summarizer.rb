# Copyright (C) 2011-2012 Kenichi Kamiya

require 'csv'
require_relative 'networknodemanager/ovtopodump_rrisc'

module NNM_OVTopodump_Summarizer

  include NetworkNodeManager

  CSV_HEADERS = %w[NodeID InterfaceID Flag Hostname MainIP IP Status j/Enable? j/Valid?]
  CSV_OPTIONS = {headers: CSV_HEADERS, write_headers: true}.freeze

  module_function
  
  def run(pathnames)
    pathnames.each do |path|
      begin
        nodes = OvTopoDump_rRISC.load_nodes path
      rescue Exception
        open "#{path}.error.log", 'w' do |f|
          f.puts($!.inspect, $!.message, $!.backtrace)
        end
      else
        CSV.open "#{path}.summary.csv", 'w', CSV_OPTIONS do |csv|
          nodes.each do |node|
            node.interfaces.each do |interface|
              csv << [
                node.id, 
                interface.id,
                interface.flag,
                node.hostname,
                node.ipaddress,
                interface.ipaddress,
                interface.status,
                interface.enable?,
                interface.ovvalid?
              ]
            end
          end
        end
      end
    end
  end

end

