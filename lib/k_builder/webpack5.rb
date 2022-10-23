# frozen_string_literal: true

require 'json'
require 'k_builder'
require 'k_builder/package_json'
require 'k_builder/webpack5/json_data'
require 'k_builder/webpack5/webpack_builder'
require 'k_builder/webpack5/webpack_json_factory'
require 'k_builder/webpack5/version'

module KBuilder
  module Webpack5
    # raise KBuilder::Webpack5::Error, 'Sample message'
    class Error < StandardError; end

    # Your code goes here...
  end
end

if ENV.fetch('KLUE_DEBUG', 'false').downcase == 'true'
  namespace = 'KBuilder::Webpack5::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_builder/webpack5/version') }
  version   = KBuilder::Webpack5::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
