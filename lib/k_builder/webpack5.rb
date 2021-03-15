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
