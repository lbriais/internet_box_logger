

require 'open-uri'

module InternetBox
  module Parsers
    module FreeboxV5

      STATUS_URL = 'http://mafreebox.free.fr/pub/fbx_info.txt'

      ETL_DATA = [
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

      ETL_POST_PROCESSING = {
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


      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end


      module ClassMethods
        UP_DOWN_REPORTS = {
            adsl_noise_margin: 'Noise Margin',
            adsl_atm_bandwidth: 'ATM Bandwidth',
            adsl_attenuation: 'Attenuation',
            adsl_crc: 'CRC',
            adsl_fec: 'FEC',
            adsl_hec: 'HEC'
        }

        def etl
          self.new.parse_status_page
        end

        def up_down_reports
          UP_DOWN_REPORTS
        end
      end

      def parse_status_page
        parser = ETL_DATA.dup
        current_parser = nil
        @last_raw_status = []
        skip_parsing = false
        open(STATUS_URL).readlines.each do |line|
          @last_raw_status << line
          next if skip_parsing
          begin
            current_parser = parser.shift if current_parser.nil?
          rescue
            Rails.logger.info "Got all data. Do not parse the rest of the data."
            skip_parsing = true
          end
          break if current_parser.nil?
          line.encode('utf-8').match current_parser do |md|
            md.names.each do |field|
              Rails.logger.info "#{field} => #{md[field]}"
              self.send "#{field}=", normalize_value(field.to_sym, md)
              current_parser = nil
            end
          end
        end
        self
      end

      private

      CONSIDERED_TRUE = %w(actif active activée activé ok true connectée connecté on décroché 1)
      CONSIDERED_FALSE = %w(inactif inactive desactivé desactivée deconnecté deconnectée désactivé désactivée déconnecté déconnectée ko false off raccroché 0)

      def normalize_value field_name, match_data
        return match_data[field_name] unless ETL_POST_PROCESSING[field_name]
        self.send ETL_POST_PROCESSING[field_name], field_name, match_data[field_name]
      end

      def to_int field_name, value_to_convert
        value_to_convert.match /^(?<num_value>[[:digit:]]+)$/i do |md|
          return md[:num_value].to_i
        end
        Rails.logger.warn "Cannot convert #{value_to_convert.inspect} to integer for field #{field_name} !"
        nil
      end

      def to_num field_name, value_to_convert
        value_to_convert.match /^(?<num_value>[[:digit:]\.\s,]+)$/i do |md|
          return md[:num_value].to_f
        end
        Rails.logger.warn "Cannot convert #{value_to_convert.inspect} to num for field #{field_name} !"
        nil
      end

      def to_db field_name, value_to_convert
        value_to_convert.match /^(?<num_value>.+) db$/i do |md|
          return to_num(field_name, md[:num_value])
        end
        Rails.logger.warn "Cannot convert #{value_to_convert.inspect} to db for field #{field_name} !"
        nil
      end

      def to_bool field_name, value_to_convert
        CONSIDERED_TRUE.each do |val|
          return true if value_to_convert.match /^#{val}$/i
        end
        CONSIDERED_FALSE.each do |val|
          return false if value_to_convert.match /^#{val}$/i
        end
        Rails.logger.warn "Cannot convert #{value_to_convert.inspect} to boolean for field #{field_name} !"
        nil
      end


      def to_duration field_name, value_to_convert
        # 9 jours, 22 heures, 42 minutes
        value_to_convert.match /(?<days>\d+)\s*jours?,\s*(?<hours>\d+)\s*heures?,\s*(?<minutes>\d+)\s*minutes?/i do |md|
          d = md[:days].present? ? md[:days].to_i : 0
          h = md[:hours].present? ? md[:hours].to_i : 0
          m = md[:minutes].present? ? md[:minutes].to_i : 0
          return d.days + h.hours + m.minutes
        end
        Rails.logger.warn "Cannot convert #{value_to_convert.inspect} to time duration (integer) for field #{field_name} !"
        nil
      end


      def to_bandwidth field_name, value_to_convert
        value_to_convert.match /^\s*(?<val>[\d\.]+)\s+(?<unit>[kKMmGg])b\/s/ do |md|
          mult = case md[:unit]
                   when 'k', 'K' then 1024
                   when 'm', 'M' then 1024 * 1024
                   when 'g', 'G' then 1024 * 1024
                 end
          return md[:val].to_f * mult
        end

        Rails.logger.warn "Cannot convert #{value_to_convert.inspect} to time duration (integer) for field #{field_name} !"
        nil
      end

    end

  end
end