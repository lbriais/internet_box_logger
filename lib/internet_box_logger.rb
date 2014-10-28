require 'internet_box_logger/version'
require 'internet_box_logger/generic_box'
require 'easy_app_helper'

module InternetBoxLogger

  module Parsers
    def self.list
      constants.dup.keep_if {|c| const_get(c.to_s).is_a? Module}.map {|m| const_get m}
    end
  end

  def self.get_box(box_type=EasyAppHelper.config[:box_type])
    InternetBoxLogger::GenericBox.new box_type
  end

end
