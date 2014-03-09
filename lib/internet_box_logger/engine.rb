#-------------------------------------------------------------------------------
#
#
# Copyright (c) 2014 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

module InternetBoxLogger
  class Engine < ::Rails::Engine
    isolate_namespace InternetBoxLogger

    # Defaut Elasticsearch configuration
    # Can be overriden in app's environments files.
    config.elastic_servers = ['127.0.0.1:9200']

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

#    config.load_paths += Dir["#{RAILS_ROOT}/app/models/*"].find_all { |f| File.stat(f).directory? }

  end
end
