require 'internet_box_logger/parsers/utils'
require 'internet_box_logger/parsers/freebox_v5_parser'

module InternetBoxLogger
  module Parsers

    def self.[]
      constants.dup.keep_if {|c| const_get(c.to_s).is_a? Module and c.to_s =~ /\wParser$/ } .map {|m| const_get m}
    end

  end
end
