require 'internet_box_logger/parsers/freebox_v5'

module InternetBoxLogger
  class Facade

    def initialize(box_type)
      self.extend box_type
    end

    def log_box_info

    end

  end
end