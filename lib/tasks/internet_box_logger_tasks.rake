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
    task :info do
      raise "No Kibana installation found in '#{kibana_path}'" unless valid_kibana_path?(kibana_path)
    end


    desc 'Installs Kibana in the vendor directory'
    task :install

    desc 'Create link to the actual place you installed Kibana'
    task :link_to, :kibana_path do |t, args|
      kibana_path = args.kibana_path.nil? ? ARGV.pop : args.kibana_path
      raise 'Please provide a valid Kibana installation path' if kibana_path == t.name
      raise "No Kibana installation found in '#{kibana_path}'" unless valid_kibana_path?(kibana_path)
      puts "Installing Kibana from path '#{kibana_path}'"
      suppress_symlink_only kibana_symlink_path
      puts "Creating new link to Kibana installation '#{kibana_path}'"
      File.symlink kibana_path, kibana_symlink_path
      puts 'Done'
    end


    desc 'Loads default JSON reports into ElasticSearch for Kibana display'
    task :load_reports do
      store_es_kibana_dashboard 'Test1', '/home/laurent/devel/ruby/rails/engines/internet_box_logger/config/kibana_reports/FreboxV5.json'
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
