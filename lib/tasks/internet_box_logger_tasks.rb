require 'tempfile'

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

module InternetBoxLogger
  module Tasks
    def ibl_gem_path
      spec = Gem::Specification.find_by_name('internet_box_logger')
      File.expand_path "../#{spec.name}", spec.spec_dir
    end

    def suppress_symlink_only(path)
      return unless File.exists? path
      if File.symlink? path
        File.unlink path
        puts "Removed symlink '#{path}'"
      else
        raise "Oops #{path} is not a symbolic link. You may want to manage its removal/move manually. Aborting !"
      end
    end


    module ElasticSearch

      ES_PID_FILE = '/tmp/es.pid'

      def es_binary
        es_bin_from_config = Rails.configuration.respond_to?(:elastic_binary) ? Rails.configuration.elastic_binary : 'elasticsearch'
        es_bin = File.is_executable?(es_bin_from_config)
        raise "Cannot find executable for ElasticSearch with name '#{es_bin_from_config}'. Try setting-up elastic_binary in application config." if es_bin.nil?
        raise "You have not enough rights to run '#{es_bin_from_config}'." unless es_bin
        es_bin
      end

      def already_running?
        !es_pid.nil?
      end

      def es_pid
        pid = `ps aux | grep 'elasticsearc[h]' | awk '{ print $2 }'`
        return nil if pid.nil? || pid.empty?
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


    end

    module Cron

      def whenever_conf_file
        "#{ibl_gem_path}/config/schedule.rb"
      end

    end

    module Kibana


      def kibana_symlink_path
        "#{Rails.configuration.root}/public/kibana"
      end


      def valid_kibana_path? path
        File.exists? "#{path}/index.html"
      end
    end


  end
end