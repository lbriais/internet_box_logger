
module InternetBoxLogger
  class GenericBox

    include InternetBoxLogger::ElasticSearch

    def initialize(box_type)
      box_type = box_type.to_s if box_type.is_a? Symbol
      box_type = box_type.constantize if box_type.is_a? String
      box_parser_module = box_type if InternetBoxLogger::Parsers[].include? box_type
      self.extend box_parser_module if box_parser_module
      raise NameError unless box_parser_module
    rescue NameError => e
      EasyAppHelper.logger.error "This box type (#{box_type}) doesn\'t seem to exist for now..\nYou can watch the gem's repo for new boxes or create your own wih a pull request."
    end

    def log_box_info
      save if get_box_data
    end



  end
end
