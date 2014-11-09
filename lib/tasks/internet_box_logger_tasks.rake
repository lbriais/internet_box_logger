require File.expand_path '../internet_box_logger_tasks.rb', __FILE__


namespace :internet_box_logger do

  include InternetBoxLogger::Tasks

  task :booted_environment do
    require 'internet_box_logger'
    EasyAppHelper.config.script_filename = File.expand_path "#{ibl_gem_path}/config/internet_box_logger.conf", __FILE__
  end

  # ElasticSearch tasks
  namespace :es do

    include InternetBoxLogger::Tasks::ElasticSearch

    desc 'Starts your local ElasticSearch server'
    task :start => :booted_environment  do
      if already_running?
        puts 'ElasticSearch already running... Aborting'
        next
      end
      spawn("#{es_binary} -d")
      puts 'ElasticSearch server started'
    end

    desc 'Stops your local ElasticSearch server'
    task :stop do
      unless already_running?
        puts 'ElasticSearch is not running... Nothing to stop'
        next
      end
      pid = es_pid
      raise 'Invalid operation on pid file' if pid.nil? || pid < 1
      Process.kill('SIGTERM', pid)
      puts 'ElasticSearch stopped'
    end

    desc 'Show your local ElasticSearch config'
    task :info => :booted_environment do
      puts "config.elastic_servers = #{InternetBoxLogger::ElasticSearch::Server[]}"
      puts "config.elastic_binary = #{es_binary}"
      puts "ElasticSearch server is currently #{%w{stopped running}[es_pid.nil? ? 0 : 1 ]}."
    end
  end


  # Kibana tasks
  namespace :kibana do

    include InternetBoxLogger::Tasks::Kibana

    desc 'Displays Kibana information'
    task :info => :booted_environment do
      if valid_kibana_path?(kibana_path)
        puts "A valid Kibana install has been found in #{kibana_path}"
      else
        raise <<EOM
No Kibana installation found in '#{kibana_path}'.
  You may want to update 'kibana_path' in your config to be able to use the 'deploy' target.

  If Kibana is not on the machine this gem is installed you may have to manually copy files located in:
    - #{ibl_gem_path}/config/kibana_reports
  into your Kibana dashboards path:
    - <place where your Kibana is installed>/app/dashboards

EOM
      end
    end

    desc 'Deploys box specific reports into Kibana dashboards directory'
    task :deploy => :info do
      kibana_reports_source.each do |report_file|
        puts " - Installing '#{report_file}' to '#{kibana_dashboards_path}'"
        options = {}
        FileUtils.cp report_file, kibana_dashboards_path, options
      end
    end

  end

  # Cron tasks
  namespace :cron do

    include InternetBoxLogger::Tasks::Cron

    desc 'Setup cron to gather information every x minutes (configurable)'
    task :setup => :booted_environment do
      puts "Using Whenever config file: '#{whenever_conf_file}' with interval #{EasyAppHelper.config[:cron_interval]}"
      rake_system "whenever -f '#{whenever_conf_file}' -i '#{whenever_conf_file}' -s interval='#{EasyAppHelper.config[:cron_interval]}'"
      puts 'Crontab updated'
    end

    desc 'Removes cron task'
    task :remove do
      puts "Using Whenever config file: '#{whenever_conf_file}'"
      rake_system "whenever -c '#{whenever_conf_file}'"
      puts 'Crontab updated'
    end

    desc 'Show your Cron config'
    task :info => :booted_environment do
      puts "Whenever config file used = #{whenever_conf_file}'"
      puts "config.cron_interval = #{EasyAppHelper.config[:cron_interval]}"
    end
  end



end
