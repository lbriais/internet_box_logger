module InternetBoxLogger
  module ElasticSearch

    include EasyAppHelper

    def elasticsearch_client
      @elasticsearch_client ||= Elasticsearch::Client.new hosts: config[:elastic_servers],
                                                          log: true,
                                                          reload_connections: true
    end

    def save
      internal_representation = []
      self.as_es_documents.each do |document|
        internal_representation << elasticsearch_client.index(**document)
      end
      logger.debug 'Saving to ElasticSearch'
      @internal_es_representation = internal_representation
      self
    rescue
      logger.warn 'Unable to save to ElasticSearch !!'
    end

  end
end
