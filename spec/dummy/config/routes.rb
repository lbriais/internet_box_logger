Rails.application.routes.draw do

  mount FreeboxLogger::Engine => "/freebox_logger"
end
