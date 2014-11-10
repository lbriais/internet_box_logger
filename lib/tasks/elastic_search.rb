module InternetBoxLogger
  module Tasks
    module ElasticSearch

      ES_PID_FILE = '/tmp/es.pid'

      def es_binary
        es_bin_from_config = InternetBoxLogger::ElasticSearch::Server.local_path
        es_bin = File.is_executable? es_bin_from_config
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

      def start_es_server
        if already_running?
          EasyAppHelper.puts_and_logs 'ElasticSearch already running... Aborting'
          return nil
        end
        spawn("#{es_binary} -d")
        EasyAppHelper.puts_and_logs 'ElasticSearch server started'
        true
      end

      def stop_es_server
        unless already_running?
          EasyAppHelper.puts_and_logs 'ElasticSearch is not running... Nothing to stop'
          return nil
        end
        pid = es_pid
        raise 'Invalid operation on pid file' if pid.nil? || pid < 1
        Process.kill('SIGTERM', pid)
        EasyAppHelper.puts_and_logs 'ElasticSearch stopped'
        true
      end

    end
  end
end
