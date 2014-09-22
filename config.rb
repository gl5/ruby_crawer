#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'

module RubyCrawler
  module Config

    @@hash = YAML.load_file("./config/setting.yml")

    class << self

      def set(key, value)
      end

      def get(key, default = nil)
        current = @@hash
        keys = key.split('.')

        keys.each do |k|
          if current and current.is_a?(Hash)
            current = current.key?(k) ? current[k] : default
          end
        end
        current
      end

    end
  end
end
