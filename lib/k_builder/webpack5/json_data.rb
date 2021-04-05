# frozen_string_literal: true

module KBuilder
  module Webpack5
    # Represents a node in a JSON object
    class JsonData < OpenStruct
      def self.parse_json(json)
        json = json.to_json if json.is_a?(Hash)
        JSON.parse(json, object_class: JsonData)
      end

      def as_json
        KUtil.data.to_hash(self)
      end
    end
  end
end
