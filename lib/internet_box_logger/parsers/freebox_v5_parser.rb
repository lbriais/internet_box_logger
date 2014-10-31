require 'open-uri'

module InternetBoxLogger
  module Parsers
    module FreeboxV5Parser

      include EasyAppHelper
      include InternetBoxLogger::Parsers::Utils

      DEFAULT_STATUS_URL = 'http://mafreebox.free.fr/pub/fbx_info.txt'

      EXPECTED_LINES = [
          /version du firmware\s+(?<firmware_version>[\d\.]+)\s*$/i ,
          /mode de connection\s+(?<connection_mode>[[:alpha:]]+)\s*$/i ,
          /temps depuis la mise en route\s+(?<up_time>.*)$/i ,
          /etat\s+(?<phone_status>[[:alpha:]]+)\s*$/i ,
          /etat du combiné\s+(?<phone_hanged_up>[[:alpha:]]+)\s*$/i ,
          /sonnerie\s+(?<phone_ringing>[[:alpha:]]+)\s*$/i ,
          /etat\s+(?<adsl_status>[[:alpha:]]+)\s*$/i ,
          /protocole\s+(?<adsl_protocol>[^\s]+)\s*$/i ,
          /mode\s+(?<adsl_mode>[[:alpha:]]+)\s*$/i ,
          /débit atm\s+(?<adsl_atm_bandwidth_down>[\d\.]+\s+[^\s]+)\s+(?<adsl_atm_bandwidth_up>[\d\.]+\s+[^\s]+)\s*$/i ,
          /marge de bruit\s+(?<adsl_noise_margin_down>[\d\.]+\s+[^\s]+)\s+(?<adsl_noise_margin_up>[\d\.]+\s+[^\s]+)\s*$/i ,
          /atténuation\s+(?<adsl_attenuation_down>[\d\.]+\s+[^\s]+)\s+(?<adsl_attenuation_up>[\d\.]+\s+[^\s]+)\s*$/i ,
          /fec\s+(?<adsl_fec_down>\d+)\s+(?<adsl_fec_up>\d+)\s*$/i ,
          /crc\s+(?<adsl_crc_down>\d+)\s+(?<adsl_crc_up>\d+)\s*$/i ,
          /hec\s+(?<adsl_hec_down>\d+)\s+(?<adsl_hec_up>\d+)\s*$/i ,
          /etat\s+wifi\s+(?<wifi_state>[[:alpha:]]+)\s*$/i ,
          /canal\s+(?<wifi_chanel>[\d]+)\s*$/i ,
          /tat du r[eé]seau\s+(?<wifi_network_state>[[:alpha:]]+)\s*$/i ,
          /freewifi\s+(?<wifi_freewifi_state>[[:alpha:]]+)\s*$/i ,
          /freewifi secure\s+(?<wifi_freewifi_secure_state>[[:alpha:]]+)\s*$/i ,
          /adresse mac freebox\s+(?<network_mac>[\dabcdefABCDEF:]+)\s*$/i ,
          /\s+(?<network_public_ipv4>[\d\.]+)\s*$/i ,
          /mode routeur\s+(?<network_router>[[:alpha:]]+)\s*$/i ,
          /adresse ip privée\s+(?<network_private_ipv4>[\d\.]+)\s*$/i ,
          /adresse ip dmz\s+(?<network_dmz_ipv4>[\d\.]+)\s*$/i ,
          /adresse ip freeplayer\s+(?<network_freeplayer_ipv4>[\d\.]+)\s*$/i ,
          /réponse au ping\s+(?<network_answer_to_ping>[[:alpha:]]+)\s*$/i ,
          /proxy wake on lan\s+(?<network_wake_on_lan>[[:alpha:]]+)\s*$/i ,
          /serveur dhcp\s+(?<network_dhcp>[[:alpha:]]+)\s*$/i ,
          /plage d'adresses dynamiques?\s+(?<network_dhcp_range>[\d\.\s-]+[^\s])\s*$/i ,
      ]

      FIELD_POST_PROCESSING = {
          up_time: :to_duration,
          phone_status: :to_bool,
          phone_hanged_up: :to_bool,
          phone_ringing: :to_bool,
          wifi_chanel: :to_int,
          wifi_state: :to_bool,
          wifi_network_state: :to_bool,
          wifi_freewifi_state: :to_bool,
          wifi_freewifi_secure_state: :to_bool,
          network_answer_to_ping: :to_bool,
          network_wake_on_lan: :to_bool,
          network_dhcp: :to_bool,
          network_router: :to_bool,
          adsl_atm_bandwidth_up: :to_bandwidth,
          adsl_atm_bandwidth_down: :to_bandwidth,
          adsl_noise_margin_up: :to_db,
          adsl_noise_margin_down: :to_db,
          adsl_attenuation_up: :to_db,
          adsl_attenuation_down: :to_db,
          adsl_crc_up: :to_num,
          adsl_crc_down: :to_num,
          adsl_fec_up: :to_num,
          adsl_fec_down: :to_num,
          adsl_hec_up: :to_num,
          adsl_hec_down: :to_num,
      }

      UP_DOWN_REPORTS = {
          adsl_noise_margin: 'Noise Margin',
          adsl_atm_bandwidth: 'ATM Bandwidth',
          adsl_attenuation: 'Attenuation',
          adsl_crc: 'CRC',
          adsl_fec: 'FEC',
          adsl_hec: 'HEC'
      }

      attr_accessor :raw_data, :attributes

      def get_status_url
        config[:freebox_alternate_url] ? config[:freebox_alternate_url] : DEFAULT_STATUS_URL
      end

      def up_down_reports
        UP_DOWN_REPORTS
      end

      def get_box_data
        regexp_list = EXPECTED_LINES.dup
        current_regexp = nil
        @raw_data, @attributes = [], {}
        skip_parsing = false
        open(get_status_url).readlines.each do |line|
          @raw_data << line
          next if skip_parsing
          begin
            current_regexp = regexp_list.shift if current_regexp.nil?
          rescue
            EasyAppHelper.logger.info 'Got all data. Do not parse the rest of the data.'
            skip_parsing = true
          end
          break if current_regexp.nil?
          line.encode('utf-8').match current_regexp do |md|
            md.names.each do |field|
              EasyAppHelper.logger.info "#{field} => #{md[field]}"
              @attributes[field.to_sym] = normalize_value(field.to_sym, md)
              current_regexp = nil
            end
          end
        end
        # Check if the parsing has been complete
        regexp_list.empty? ? self : nil
      end


      def normalize_value(field_name, match_data)
        return match_data[field_name] unless FIELD_POST_PROCESSING[field_name]
        self.send FIELD_POST_PROCESSING[field_name], field_name, match_data[field_name]
      end


    end
  end
end