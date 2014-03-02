
class Hash
  def merge_recursive(o)
    merge(o) do |_,x,y|
      if x.respond_to?(:merge_recursive) && y.is_a?(Hash)
        x.merge_recursive(y)
      else
        [*x,*y]
      end
    end
  end
end

module FreeboxLogger
  class Engine < ::Rails::Engine
    isolate_namespace FreeboxLogger


    def self.merge_config_file filename, conf={}
      if File.exist? filename
        Rails.logger.info "Loading #{filename}"
        file_conf = YAML.load_file(filename)
        conf = conf.merge_recursive file_conf
      end
      conf
    end

    config.after_initialize  do
      app_file = File.join Rails.root,'/config/environments/', Rails.env, '/elasticsearch.yml'
      file = File.exist?(app_file) ? app_file : File.join(self.root,'/config/environments/', Rails.env, '/elasticsearch.yml')
      config.elastic_servers = YAML.load_file(file)
    end

  end
end
