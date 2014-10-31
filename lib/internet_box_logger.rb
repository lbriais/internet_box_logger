require 'internet_box_logger/version'
require 'easy_app_helper'
require 'internet_box_logger/elastic_search'
require 'internet_box_logger/generic_box'

module InternetBoxLogger

  module Parsers
    def self.list
      constants.dup.keep_if {|c| const_get(c.to_s).is_a? Module}.delete_if {|m| m =~ /Utils$/ } .map {|m| const_get m}
    end
  end

  def self.get_box(box_type=EasyAppHelper.config[:box_type])
    InternetBoxLogger::GenericBox.new box_type
  end

end
