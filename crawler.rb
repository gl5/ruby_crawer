#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'
require './config'
require './thread_pool'

module RubyCrawler
  class Crawler
    def initialize(keyword)
      @keyword = CGI::escape(keyword)
      @threads = Config.get('app.threads')
      @workers = RubyCrawler::ThreadPool.new(@threads)
    end

    def start
      @workers.schedule(:keyword, @keyword)
      @workers.join
    end
  end

  crawler = Crawler.new('你')
  crawler.start
end
