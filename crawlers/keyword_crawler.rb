#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'
require './config'
require './models/keyword'

module RubyCrawler
  class KeywordCrawler

    def initialize(keyword, socket, queue)
      @keyword = keyword
      @socket = socket
      @queue = queue
    end

    def fetch
      response = ""
      retry_limit = Config.get('app.retry_limit')
      p "fetch keyword #{CGI::unescape(@keyword)} ..."
      begin
        response = ""
        retry_limit -= 1
        @socket.write("GET /s?q=#{@keyword} HTTP/1.1\r\n")
        @socket.write("Host: www.so.com\r\n")
        @socket.write("Cache-Control: no-cache\r\n")
        @socket.write("Connection: keep-alive\r\n")
        @socket.write("\r\n")

        while line = @socket.gets
          response += line
        end
      rescue => e
        if retry_limit > 0
          sleep(5)
          retry
        else
          p "fetch keyword #{CGI::unescape(@keyword)} failed ..."
          p e.message
          return
        end
      end

      response = response.force_encoding("UTF-8")
      slice_start =  response.rindex('相关搜索')
      slice_end =  response.rindex('<!-- END #page -->')
      data = (slice_start and slice_end) ? response[slice_start...slice_end] : response
      pattern = /<th><a href=\"\/s\?q=(.+?)&src=related\" data-type=/

      keywords = data.scan(pattern)
      keywords.each do |kw|
        kw = kw.first
        if RubyCrawler::Keyword.filter({keyword: kw}).empty?
          RubyCrawler::Keyword.insert(keyword: kw)
          @queue.push([:keyword, kw])
          @queue.push([:title, kw])
        end
      end
      dataset = RubyCrawler::Keyword
      ds = dataset.first(keyword: @keyword)
      return unless ds
      ds.status = true
      ds.save
    rescue => e
      p "parse keyword #{CGI::unescape(@keyword)} failed ..."
      p e.message
    end
  end
end
