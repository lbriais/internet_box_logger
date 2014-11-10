module InternetBoxLogger
  module Tasks
    module Kibana

      def kibana_reports_source
        reports_source = "#{ibl_gem_path}/config/kibana_reports"
        Dir.entries(reports_source).keep_if {|e| e =~ /_report\.json$/i }.map {|e| "#{reports_source}/#{e}"}
      end

      def kibana_dashboards_path
        "#{kibana_path}/app/dashboards"
      end

      def kibana_path
        EasyAppHelper.config[:kibana_path]
      end

      def kibana_symlink_path
        "#{EasyAppHelper.config.root}/public/kibana"
      end


      def valid_kibana_path? path
        File.exists? "#{path}/index.html"
      end

      def kibana_info
        if valid_kibana_path?(kibana_path)
          EasyAppHelper.puts_and_logs "A valid Kibana install has been found in #{kibana_path}"
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


      def deploy_reports
        kibana_reports_source.each do |report_file|
          EasyAppHelper.puts_and_logs " - Installing '#{report_file}' to '#{kibana_dashboards_path}'"
          options = {}
          FileUtils.cp report_file, kibana_dashboards_path, options
        end
      end

      def serve_ui(port=EasyAppHelper.config[:server_port])
        require 'webrick'
        port ||= EasyAppHelper.config[:server_port]
        WEBrick::HTTPServer.new(:Port => port, :DocumentRoot => kibana_path).start
      end


    end
  end
end