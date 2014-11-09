module InternetBoxLogger
  module ElasticSearch

    module Server

      def self.[]
        EasyAppHelper.config[:elastic_servers] || EasyAppHelper.config[:default_elastic_search]['elastic_servers']
      end

      def self.local_path
        EasyAppHelper.config[:elastic_binary] || EasyAppHelper.config[:default_elastic_search]['elastic_binary']
      end

      def self.local?
        !remote?
      end

      def self.manageable?
        !(remote? || local_path.nil? )
      end

      def self.remote?
        # res = true
        # return nil if Server[].nil? || Server.empty?
        # Server[].each do |addr|
        #   if
        #
        #   end
        # end
        local_path.nil?
      end

    end




    def elasticsearch_client
      @elasticsearch_client ||= Elasticsearch::Client.new hosts: Server[], log: EasyAppHelper.config[:debug], reload_connections: true
    end

    def save
      internal_representation = []
      self.as_es_documents.each do |document|
        internal_representation << elasticsearch_client.index(**document)
      end
      EasyAppHelper.logger.debug 'Saving to ElasticSearch'
      @internal_es_representation = internal_representation
      EasyAppHelper.puts_and_logs 'Your box metrics have been indexed into Elastic Search'
      self
    rescue
      EasyAppHelper.logger.error 'Unable to save to ElasticSearch !!'
    end

  end
end
