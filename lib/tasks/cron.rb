module InternetBoxLogger
  module Tasks
    module Cron

      def whenever_conf_file
        "#{ibl_gem_path}/config/schedule.rb"
      end

      def cron_setup
        EasyAppHelper.puts_and_logs "Using Whenever config file: '#{whenever_conf_file}' with interval #{EasyAppHelper.config[:cron_interval]}"
        system "whenever -f '#{whenever_conf_file}' -i '#{whenever_conf_file}' -s interval='#{EasyAppHelper.config[:cron_interval]}'"
        EasyAppHelper.puts_and_logs 'Crontab updated'
      end

      def cron_remove
        EasyAppHelper.puts_and_logs "Using Whenever config file: '#{whenever_conf_file}'"
        system "whenever -c '#{whenever_conf_file}'"
        EasyAppHelper.puts_and_logs 'Crontab updated'
      end

      def cron_info
        EasyAppHelper.puts_and_logs "Whenever config file used = #{whenever_conf_file}'"
        EasyAppHelper.puts_and_logs "config.cron_interval = #{EasyAppHelper.config[:cron_interval]}"
      end

    end
  end
end
