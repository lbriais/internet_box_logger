

namespace :internet_box_logger do


  class File

    def self.is_executable?(filename)
      real_name = nil
      if exists?(filename)
        real_name = filename
      else
        ENV['PATH'].split(':').each do |d|
          f = join(d, filename)
          if exists? f
            real_name = f
            break
          end
        end
      end
      return nil if real_name.nil? || real_name.blank?
      executable_real?(real_name) ? real_name : false
    end

    def self.exists_in_path?(filename)
      ENV['PATH'].split(':').collect do |d|
        Dir.entries d if Dir.exists? d
      end.flatten.include?(filename) ? filename : false
    end

  end

  def ibl_gem_path
    spec = Gem::Specification.find_by_name('internet_box_logger')
    File.expand_path "../#{spec.name}", spec.spec_dir
  end


  # ElasticSearch tasks
  namespace :es do

    ES_PID_FILE = '/tmp/es.pid'

    def es_binary
      es_bin_from_config = Rails.configuration.respond_to?(:elastic_binary) ? Rails.configuration.elastic_binary : 'elasticsearch'
      es_bin = File.is_executable?(es_bin_from_config)
      raise "Cannot find executable for ElasticSearch with name '#{es_bin_from_config}'. Try setting-up elastic_binary in application config." if es_bin.nil?
      raise "You have not enough rights to run '#{es_bin_from_config}'." unless es_bin
      es_bin
    end

    def already_running?
      File.exists? ES_PID_FILE
    end

    def es_pid
      pid = nil
      return pid unless already_running?
      File.open(ES_PID_FILE) do |f|
        pid = f.gets
        puts "PID: #{pid}"
      end
      pid.to_i
    end


    def create_pid_file(pid=nil)
      if block_given?
        File.open(ES_PID_FILE, 'w+') do |f|
          yield f
        end
        pid = es_pid
        raise "Invalid operation on pid file" if pid.nil? || pid < 1
      else
        raise "Specify a pid or a block !" if pid.nil?
        raise "Invalid pid!" unless pid.is_a? Fixnum
        File.open(ES_PID_FILE, 'w+') do |f|
          f.puts pid
        end
      end
      pid
    end

    desc 'Starts your ElasticSearch server'
    task :start => :environment do
      if already_running?
        puts 'ElasticSearch already running... Aborting'
        next
      end
      pid = create_pid_file do |pid_file|
        pid_file.puts spawn("#{es_binary} -d")
      end
      puts "ElasticSearch started with pid: #{pid}"
      pid
    end

    desc 'Stops your ElasticSearch server'
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

    desc 'Show your ElasticSearch config'
    task :info => :environment do
      puts "config.elastic_servers = #{Rails.configuration.elastic_servers}"
      puts "config.elastic_binary = #{es_binary}"
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

    def whenever_conf_file
      "#{ibl_gem_path}/config/schedule.rb"
    end

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
