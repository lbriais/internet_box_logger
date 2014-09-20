


namespace :internet_box_logger do

  def ibl_gem_path
    spec = Gem::Specification.find_by_name('internet_box_logger')
    File.expand_path "../#{spec.name}", spec.spec_dir
  end

  # ElasticSearch tasks
  namespace :es do

    def es_binary
      bin = Rails.configuration.respond_to?(:elastic_binary) ? Rails.configuration.elastic_binary : 'elastic_search'
      unless File.exists?(bin) || ENV['PATH'].split(':').collect {|d| Dir.entries d if Dir.exists? d}.flatten.include?(bin)
        raise "Your ElasticSearch server (#{bin}) has not been declared properly. Try setting-up elastic_binary in application config."
      end
      bin
    end

    desc "Starts your ElasticSearch server"
    task :start => :environment do
      puts es_binary
    end

    desc "Stops your ElasticSearch server"
    task :stop => :environment do
      puts es_binary
    end

    desc "Show your ElasticSearch config"
    task :info => :environment do
      puts "config.elastic_servers = #{Rails.configuration.elastic_servers}"
      puts "config.elastic_binary = #{es_binary}"
    end


  end

  # Cron tasks
  namespace :cron do

    def whenever_conf_file
      "#{ibl_gem_path}/config/schedule.rb"
    end

    desc "Setup cron to gather information every x minutes (configurable)"
    task :setup => :environment do
      puts "Using Whenever config file: '#{whenever_conf_file}' with interval #{Rails.configuration.cron_interval}"
      rake_system "whenever -f '#{whenever_conf_file}' -i '#{whenever_conf_file}' -s 'interval=#{Rails.configuration.cron_interval}'"
      puts 'Crontab updated'
    end

    desc "Removes cron task"
    task :stop do
      puts "Using Whenever config file: '#{whenever_conf_file}'"
      rake_system "whenever -c '#{whenever_conf_file}'"
      puts 'Crontab updated'
    end

    desc "Show your Cron config"
    task :info => :environment do
      puts "Whenever config file used = #{whenever_conf_file}'"
      puts "config.cron_interval = #{Rails.configuration.cron_interval}"
    end
  end



end
