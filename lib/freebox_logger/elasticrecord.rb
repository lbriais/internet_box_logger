#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2014 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'elasticsearch'

module Elasticsearch

  class Base

    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion

    extend ActiveModel::Naming

    def initialize attributes={}
      self.class.setup
    end


    def self.create attributes=nil
      model_instance = attributes.nil? ? etl : new(attributes)
      model_instance.save
    end

    def save
      self.created_at = Time.now
      elasticsearch_client.indices.put_mapping index: self.class.model_name.singular,
                                                          type: :measurement,
                                                          body: attributes
      elasticsearch_client.index index: self.class.model_name.singular,
                                                          type: :measurement,
                                                          body: attributes
      self
    end

    def attributes
      attrs = {}
      self.class.attributes.each do |attr|
        attrs[attr] = send attr
      end
      attrs
    end

    def self.attributes
      @attributes
    end

    def elasticsearch_client
      self.class.elasticsearch_client
    end

    private

    def self.setup_fields mappings
      @attributes ||= []
      mappings.keys.each do |new_attr|
        instance_variable_set("@#{new_attr}", nil)
        send(:attr_accessor, new_attr.to_sym)
        @attributes << new_attr.to_sym
      end
    end

    def self.elasticsearch_client
      @elasticsearch_client ||= Elasticsearch::Client.new hosts: Rails.configuration.elastic_servers,
                                                          log: true,
                                                          reload_connections: true
    end

    def self.load_mappings
      Rails.configuration.elastic_mappings[name.underscore.to_sym]
    end

    def self.setup
      @mappings ||= load_mappings
      setup_fields @mappings
    end

  end
end