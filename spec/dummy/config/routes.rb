Rails.application.routes.draw do

  mount InternetBoxLogger::Engine => "/internet_box_logger"
end
