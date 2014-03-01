#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2014 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'freebox_logger/status_page_parser'
require 'freebox_logger/elasticrecord'

class Freebox < Elasticsearch::Base
  #include ActiveModel::Model
  #extend ActiveModel::Naming
  #
  #attr_accessor :adsl_atm_bandwidth_down, :adsl_atm_bandwidth_up, :adsl_attenuation_down, :adsl_attenuation_up,
  #              :adsl_crc_down, :adsl_crc_up, :adsl_fec_down, :adsl_fec_up, :adsl_hec_down, :adsl_hec_up, :adsl_mode,
  #              :adsl_noise_margin_down, :adsl_noise_margin_up, :adsl_protocol, :adsl_status, :connection_mode,
  #              :created_at, :firmware_version, :network_answer_to_ping, :network_dhcp, :network_dhcp_range,
  #              :network_dmz_ipv4, :network_freeplayer_ipv4, :network_mac, :network_private_ipv4, :network_public_ipv4,
  #              :network_router, :network_wake_on_lan, :phone_hanged_up, :phone_ringing, :phone_status, :up_time,
  #              :updated_at, :wifi_chanel, :wifi_freewifi_secure_state, :wifi_freewifi_state, :wifi_network_state,
  #              :wifi_state
  #
  attr_accessor :last_raw_status
  include FreeboxLogger::StatusPageParser
  #
  #def initialize(attributes = {})
  #  attributes.each do |name, value|
  #    send("#{name}=", value)
  #  end
  #end
  #
  #def save
  #  export_to_elasticsearch
  #end
  #
  #def self.statistics_fields
  #  up_down_reports.keys.inject([:created_at]) do |fields, f|
  #    %w(up down).each { |s| fields << "#{f}_#{s}".to_sym }
  #    fields
  #  end
  #end
  #
  #
  #def persisted?
  #  false
  #end
  #
  #private
  #def export_to_elasticsearch
  #
  #  es = self.class.get_elasticsearch_connection
  #  # Index a document:
  #  # es.index index: :freebox, type: :measurement, body: self.attributes
  #
  #  # Get the document:
  #  # puts es.search index: :freebox, type: :measurement
  #
  #
  #end
  #
  #def self.get_elasticsearch_connection
  #  Elasticsearch::Client.new hosts: ['admin.nanonet:9200']
  #end
  #
  #def self.setup_fields
  #
  #end

end