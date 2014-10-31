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

    end
  end
end
