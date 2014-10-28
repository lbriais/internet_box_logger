require 'internet_box_logger/parsers/freebox_v5'

module InternetBoxLogger
  class GenericBox

    def initialize(box_type)
      box_type = box_type.to_s if box_type.is_a? Symbol
      box_type = const_get box_type if box_type.is_a? String
      box_parser_module = box_type if InternetBoxLogger::Parsers.list.include? box_type
      self.extend box_parser_module
    end

    def log_box_info

    end



  end
end
