module InternetBoxLogger
  module Parsers
    module Utils

      CONSIDERED_TRUE = %w(actif active activée activé ok true connectée connecté on décroché 1)
      CONSIDERED_FALSE = %w(inactif inactive desactivé desactivée deconnecté deconnectée désactivé désactivée déconnecté déconnectée ko false off raccroché 0)

      def to_bandwidth(field_name, value_to_convert)
        value_to_convert.match /^\s*(?<val>[\d\.]+)\s+(?<unit>[kKMmGg])b\/s/ do |md|
          mult = case md[:unit]
                   when 'k', 'K' then
                     1024
                   when 'm', 'M' then
                     1024 * 1024
                   when 'g', 'G' then
                     1024 * 1024
                 end
          return md[:val].to_f * mult
        end

        EasyAppHelper.logger.warn "Cannot convert #{value_to_convert.inspect} to time duration (integer) for field #{field_name} !"
        nil
      end

      def to_duration(field_name, value_to_convert)
        # 9 jours, 22 heures, 42 minutes
        value_to_convert.match /(?<days>\d+)\s*jours?,\s*(?<hours>\d+)\s*heures?,\s*(?<minutes>\d+)\s*minutes?/i do |md|
          d = md[:days].nil? ? 0 : md[:days].to_i
          h = md[:hours].nil? ? 0 : md[:hours].to_i
          m = md[:minutes].nil? ? 0 : md[:minutes].to_i
          return d * 86400 + h * 3600 + m * 60
        end
        EasyAppHelper.logger.warn "Cannot convert #{value_to_convert.inspect} to time duration (integer) for field #{field_name} !"
        nil
      end

      def to_bool(field_name, value_to_convert)
        CONSIDERED_TRUE.each do |val|
          return true if value_to_convert.match /^#{val}$/i
        end
        CONSIDERED_FALSE.each do |val|
          return false if value_to_convert.match /^#{val}$/i
        end
        EasyAppHelper.logger.warn "Cannot convert #{value_to_convert.inspect} to boolean for field #{field_name} !"
        nil
      end

      def to_db(field_name, value_to_convert)
        value_to_convert.match /^(?<num_value>.+) db$/i do |md|
          return to_num(field_name, md[:num_value])
        end
        EasyAppHelper.logger.warn "Cannot convert #{value_to_convert.inspect} to db for field #{field_name} !"
        nil
      end

      def to_num(field_name, value_to_convert)
        value_to_convert.match /^(?<num_value>[[:digit:]\.\s,]+)$/i do |md|
          return md[:num_value].to_f
        end
        EasyAppHelper.logger.warn "Cannot convert #{value_to_convert.inspect} to num for field #{field_name} !"
        nil
      end

      def to_int(field_name, value_to_convert)
        value_to_convert.match /^(?<num_value>[[:digit:]]+)$/i do |md|
          return md[:num_value].to_i
        end
        EasyAppHelper.logger.warn "Cannot convert #{value_to_convert.inspect} to integer for field #{field_name} !"
        nil
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
                value: attributes[data_name.to_sym]
            }
            es_object[:body] = data
            res << es_object
          end
        end
        generic_info = {}

        attributes.each do |attr_name, content|
          next if attr_name.length > 3 && self.up_down_reports.keys.include?(attr_name.to_s.gsub(/_(up|down)$/, '').to_sym)
          generic_info[attr_name] = content
        end
        generic_info[:name] = 'generic'
        res << {
            index: "#{self.class.name.underscore.tr('/', '_')}_generic",
            type: :info,
            body: generic_info
        }

        res
      end



    end
  end
end
