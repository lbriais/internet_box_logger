#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2014 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'freebox_logger/status_page_parser'
require 'freebox_logger/elasticrecord'

class Freebox < Elasticsearch::Base
  attr_accessor :last_raw_status

  include FreeboxLogger::StatusPageParser



end