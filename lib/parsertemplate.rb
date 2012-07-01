# Copyright (C) 2011 Kenichi Kamiya

require 'forwardable'
require 'strscan'

module Parsable

  def parse(str)
    self::Parser.parse str
  end
  
  def for_io(io)
    parse io.read
  end
  
  def load(path)
    open path do |f|
      return for_io(f)
    end
  end

end

class ParserTemplate

  extend Forwardable
  private_class_method(*Forwardable.instance_methods(false))
  
  class MalformedSourceError < StandardError; end
  private_constant :MalformedSourceError

  class << self
  
    def parse(str)
      new(str).parse
    end

  end
  
  attr_reader :result
  
  def initialize(str)
    @s = @scanner = StringScanner.new str
  end

  def inspect
      [ "Scanner: #{@scanner.inspect}",
        "Rest: \n#{rest.lines.first.inspect}",
      ].join("\n")
  end

  def_delegators :@scanner, :scan, :scan_until, :eos?, :rest, :terminate
  private :scan, :scan_until, :eos?, :rest, :terminate

  private
  
  def error(message="unknown format")
    raise MalformedSourceError,"#{message}\n#{inspect}"
  end

  def trim_blank
    scan(/\s+/)
  end
  
  def trim_eos
    scan(/\n/)
  end
  
  def trim_header
    trim_blank
  end
  
  def trim_footer
    trim_blank
    trim_eos
  end

end