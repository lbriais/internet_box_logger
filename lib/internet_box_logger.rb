require 'active_support/all'
require 'easy_app_helper'

require 'internet_box_logger/version'
require 'internet_box_logger/elastic_search'
require 'internet_box_logger/parsers'
require 'internet_box_logger/generic_box'


module InternetBoxLogger

  def self.get_box(box_type=EasyAppHelper.config[:box_type])
    InternetBoxLogger::GenericBox.new box_type
  end

end
