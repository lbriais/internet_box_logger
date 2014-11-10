require 'rubygems'
require 'bundler/setup'

require File.expand_path '../internet_box_logger_tasks.rb', __FILE__


namespace :internet_box_logger do

  include InternetBoxLogger::Tasks

  task :booted_environment do
    require 'internet_box_logger'
    EasyAppHelper.config.script_filename = "#{ibl_gem_path}/config/internet_box_logger.conf"
    EasyAppHelper.config[:verbose] = true
  end

  # ElasticSearch tasks
  namespace :es do

    include InternetBoxLogger::Tasks::ElasticSearch

    desc 'Starts your local ElasticSearch server'
    task :start => :booted_environment  do
      next unless start_es_server
    end

    desc 'Stops your local ElasticSearch server'
    task :stop => :booted_environment do
      next unless stop_es_server
    end

    desc 'Show your local ElasticSearch config'
    task :info => :booted_environment do
      EasyAppHelper.puts_and_logs "config.elastic_servers = #{InternetBoxLogger::ElasticSearch::Server[]}"
      EasyAppHelper.puts_and_logs "config.elastic_binary = #{es_binary}"
      EasyAppHelper.puts_and_logs "ElasticSearch server is currently #{%w{stopped running}[es_pid.nil? ? 0 : 1 ]}."
    end
  end


  # Kibana tasks
  namespace :kibana do

    include InternetBoxLogger::Tasks::Kibana

    desc 'Displays Kibana information'
    task :info => :booted_environment do
      kibana_info
    end

    desc 'Deploys box specific reports into Kibana dashboards directory'
    task :deploy => :info do
      deploy_reports
    end

    desc 'Launch a simple server to serve Kibana UI. You can specify the port as parameter'
    task :serve, [:port]  => :info do |tsk, args|
      serve_ui args[:port]
    end

  end

  # Cron tasks
  namespace :cron do

    include InternetBoxLogger::Tasks::Cron

    desc 'Setup cron to gather information every x minutes (configurable)'
    task :setup => :booted_environment do
      cron_setup
    end

    desc 'Removes cron task'
    task :remove do
      cron_remove
    end

    desc 'Show your Cron config'
    task :info => :booted_environment do
      cron_info
    end
  end

end
