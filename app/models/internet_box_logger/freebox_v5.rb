#-------------------------------------------------------------------------------
#  
#
# Copyright (c) 2014 L.Briais under MIT license
# http://opensource.org/licenses/MIT
#-------------------------------------------------------------------------------

require 'internet_box_logger/parsers/freebox_v5'
require 'internet_box_logger/elastic_record'

module InternetBoxLogger
  class FreeboxV5 < ElasticRecord::Base

    attr_accessor :last_raw_status

    es_attributes :adsl_atm_bandwidth_down, :adsl_atm_bandwidth_up, :adsl_attenuation_down, :adsl_attenuation_up,
                  :adsl_crc_down, :adsl_crc_up, :adsl_fec_down, :adsl_fec_up, :adsl_hec_down, :adsl_hec_up,
                  :adsl_mode, :adsl_noise_margin_down, :adsl_noise_margin_up, :adsl_protocol, :adsl_status,
                  :connection_mode, :created_at, :firmware_version, :network_answer_to_ping, :network_dhcp,
                  :network_dhcp_range, :network_dmz_ipv4, :network_freeplayer_ipv4, :network_mac, :network_private_ipv4,
                  :network_public_ipv4, :network_router, :network_wake_on_lan, :phone_hanged_up, :phone_ringing,
                  :phone_status, :up_time, :wifi_chanel, :wifi_freewifi_secure_state, :wifi_freewifi_state,
                  :wifi_network_state, :wifi_state


    include InternetBox::Parsers::FreeboxV5

  end
end