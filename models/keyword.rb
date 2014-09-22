#!/usr/bin/env ruby
# encoding: utf-8

require 'sequel'
require './database'

module RubyCrawler
  class Keyword < Sequel::Model(DB[:keywords])
    def self.list
      ds = filter()
    end

    def self.get()
    end

  end
end
