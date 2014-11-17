require 'open-uri'
require 'nokogiri'
require 'json'

module InternetBoxLogger
  module Parsers
    module BboxTg787Parser

      include InternetBoxLogger::Parsers::Utils

      DEFAULT_BOX_HOST = '192.168.1.254'

      LINE_STATUS_URI = '/novice/line.htm'

      LINE_EXPECTED_DATA = [

      ]

      SERVICES_STATUS_URI = '/novice/index.htm'

      BOX_STATUS_URI = '/novice/gtw.htm'

      BOX_EXPECTED_LINES = [
        /serialnumber\s=\s.*?"(?<serial_number>[\d]+?)"/i ,
        /macaddress\s=\s.*?"(?<network_mac>[\dabcdefABCDEF:]+?)"/i ,
        /firmwareversion\s=\s.*?"(?<firmware_version>[\w\d\.-]+?)"/i ,
        /uptimes\s=\s.*?"(?<firmware_installation_date>[\w\d\-:]+?)"/i
      ]

      UP_DOWN_LINE_REPORTS = {
          adsl_noise_margin: 'NoiseMargin',
          adsl_attenuation: 'Attenuation'
      }

      UP_DOWN_BITRATES_REPORTS = {
          adsl_atm_bandwidth: 'InterleavedChannel'
      }

      attr_accessor :raw_data, :attributes


      def get_box_host
        EasyAppHelper.config[:bbox_alternate_host] ? EasyAppHelper.config[:bbox_alternate_host] : DEFAULT_BOX_HOST
      end

      def get_box_status_data
        doc = Nokogiri::HTML open("http://#{get_box_host}#{BOX_STATUS_URI}")
        StringIO.new doc.css('script')[-3].to_s
      end

      def get_line_status_data
        doc = Nokogiri::HTML open("http://#{get_box_host}#{LINE_STATUS_URI}")
        doc.css('script')[-3].to_s.match(/wandslstatus = eval\(.*?({[^\)]*})/m) do |m|
          JSON.parse m.captures.first
        end
      end

      def map_line_status_data
        data = get_line_status_data
        processed = {
            'adsl_status' => data['State']
        }
        %w(up down).each do |direction|
          UP_DOWN_LINE_REPORTS.each do |stat, key|
            processed["#{stat}_#{direction}"] = data["#{direction.camelcase}LinePerfs"][key]
          end
          UP_DOWN_BITRATES_REPORTS.each do |stat, key|
            processed["#{stat}_#{direction}"] = data["#{direction.camelcase}Bitrates"][key]
          end
        end
        processed.each do |k, v|
          EasyAppHelper.logger.info "#{k} => #{v}"
          @attributes[k.to_sym] = v
        end
      end

      def get_services_status_data
        doc = Nokogiri::HTML open("http://#{get_box_host}#{SERVICES_STATUS_URI}")
        StringIO.new doc.css('script')[-3].to_s
      end

      def up_down_reports
        UP_DOWN_BITRATES_REPORTS.merge UP_DOWN_LINE_REPORTS
      end

      def get_box_data
        @raw_data, @attributes = [], {}

        %w(box).each do |data|
          current_regexp = nil
          skip_parsing = false
          regexp_list = InternetBoxLogger::Parsers::BboxTg787Parser.const_get("#{data.upcase}_EXPECTED_LINES").dup
          send("get_#{data}_status_data".to_sym).readlines.each do |line|
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
                @attributes[field.to_sym] = md[field.to_sym]
                current_regexp = nil
              end
            end
          end
          # Check if the parsing has been complete
          regexp_list.empty? ? self : nil
        end

        map_line_status_data
      rescue NameError => e
        EasyAppHelper.logger.debug e
      end

      def as_es_documents(created_at=Time.now)
        res = []
        self.up_down_reports.each_pair do |measurement, name|
          %w(up down).each do |measurement_type|
            data_name = "#{measurement}_#{measurement_type}"
            es_object = {
                index: "#{self.class.name.underscore.tr('/', '_')}_#{measurement}",
                type: measurement_type
            }
            data = {
                created_at: created_at,
                name: data_name,
                description: name,
                value: attributes[data_name.to_sym].to_i
            }
            es_object[:body] = data
            res << es_object
          end
        end
        generic_info = {}

        attributes.each do |attr_name, content|
          # Tries to remove data that are up/down measurements already covered by previous collection
          data_key = attr_name.to_s.gsub(/_(up|down)$/, '').to_sym
          next if attr_name.length > 3 && self.up_down_reports.keys.include?(data_key)
          # Else adds info to generic info
          generic_info[attr_name] = content
        end
        generic_info[:name] = 'generic'
        generic_info[:created_at] = created_at

        res << {
            index: "#{self.class.name.underscore.tr('/', '_')}_generic",
            type: :info.to_s,
            body: generic_info
        }

        res
      end
    end
  end
end
