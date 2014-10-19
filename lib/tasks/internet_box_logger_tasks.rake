require 'tasks/internet_box_logger_tasks'

namespace :internet_box_logger do

  include InternetBoxLogger::Tasks

  # ElasticSearch tasks
  namespace :es do

    include InternetBoxLogger::Tasks::ElasticSearch

    desc 'Starts your local ElasticSearch server'
    task :start => :environment do
      if already_running?
        puts 'ElasticSearch already running... Aborting'
        next
      end
      spawn("#{es_binary} -d")
      puts 'ElasticSearch server started'
    end

    desc 'Stops your local ElasticSearch server'
    task :stop => :environment do
      unless already_running?
        puts 'ElasticSearch is not running... Nothing to stop'
        next
      end
      pid = es_pid
      raise "Invalid operation on pid file" if pid.nil? || pid < 1
      Process.kill("SIGTERM", pid)
      puts 'ElasticSearch stopped'
    end

    desc 'Show your local ElasticSearch config'
    task :info => :environment do
      puts "config.elastic_servers = #{Rails.configuration.elastic_servers}"
      puts "config.elastic_binary = #{es_binary}"
      puts "ElasticSearch server is currently #{%w{stopped running}[es_pid.nil? ? 0 : 1 ]}."
    end


  end


  # Kibana tasks
  namespace :kibana do

    desc 'Installs Kibana in the vendor directory'
    task :install

    desc 'Create link to the actual place you installed Kibana'
    task :link_to

    desc 'Loads default JSON reports into ElasticSearch for Kibana display'
    task :freebox_report

  end

  # Cron tasks
  namespace :cron do

    include InternetBoxLogger::Tasks::Cron

    desc 'Setup cron to gather information every x minutes (configurable)'
    task :setup => :environment do
      puts "Using Whenever config file: '#{whenever_conf_file}' with interval #{Rails.configuration.cron_interval}"
      rake_system "whenever -f '#{whenever_conf_file}' -i '#{whenever_conf_file}' -s 'interval=#{Rails.configuration.cron_interval}'"
      puts 'Crontab updated'
    end

    desc 'Removes cron task'
    task :stop do
      puts "Using Whenever config file: '#{whenever_conf_file}'"
      rake_system "whenever -c '#{whenever_conf_file}'"
      puts 'Crontab updated'
    end

    desc 'Show your Cron config'
    task :info => :environment do
      puts "Whenever config file used = #{whenever_conf_file}'"
      puts "config.cron_interval = #{Rails.configuration.cron_interval}"
    end
  end



end
