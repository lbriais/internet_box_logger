#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2014 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'elasticsearch'

module ElasticRecord

  class Base

    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Conversion

    extend ActiveModel::Naming

    attr_accessor :internal_es_representation

    def initialize attributes={}
      attributes.each do |k, v|
        puts k.to_sym
        self.attributes[k.to_sym] = v if self.class.attributes.include? k.to_sym
      end
    end


    def save
      self.created_at = Time.now
      @internal_es_representation =  elasticsearch_client.index index: self.class.model_name.singular,
                                                                     type: :measurement,
                                                                     body: attributes
      self
    end

    def attributes
      attrs = {}
      self.class.attributes.each do |attr|
        attrs[attr] = send attr
      end

      class << attrs
        def target=(t)
          @target = t
        end

        def []=(key,value)
          return unless @target.attributes.include? key.to_sym
          @target.send "#{key}=", value
        end
      end
      attrs.target = self

      attrs
    end

    def elasticsearch_client
      self.class.elasticsearch_client
    end

    def new_record?
     not saved?
    end

    def saved?
      @internal_es_representation.present? && @internal_es_representation['created'] && @internal_es_representation['_id'].present?
    end

    def inspect
      "<#{self.class.name}:#{self.object_id}: #{self.attributes.inspect}>"
    end

    def self.attributes
      @attributes
    end

    def self.create attributes=nil
      model_instance = attributes.nil? ? etl : new(attributes)
      model_instance.save
    end

    protected

    def self.es_attributes *attrs
      @attributes ||= []
      attrs.each do |new_attr|
        instance_variable_set("@#{new_attr}", nil)
        send(:attr_accessor, new_attr.to_sym)
        @attributes << new_attr.to_sym
      end
    end

    private

    def self.elasticsearch_client
      @elasticsearch_client ||= Elasticsearch::Client.new hosts: Rails.configuration.elastic_servers,
                                                          log: true,
                                                          reload_connections: true
    end


  end
end