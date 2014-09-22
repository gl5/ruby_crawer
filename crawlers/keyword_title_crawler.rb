#!/usr/bin/env ruby
# encoding: utf-8

require 'cgi'
require 'uri'
require './config'
require './models/keyword_title'

module RubyCrawler
  class KeywordTitleCrawler

    def initialize(keyword, socket, queue)
      @keyword = keyword
      @socket = socket
      @queue = queue
    end

    def fetch
      response = ""
      retry_limit = Config.get('app.retry_limit')
      p "fetching keyword_title #{CGI::unescape(@keyword)} ..."
      begin
        response = ""
        retry_limit -= 1
        @socket.write("GET /s?wd=#{@keyword} HTTP/1.1\r\n")
        @socket.write("Host: www.baidu.com\r\n")
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
          p "fetching keyword_title #{CGI::unescape(@keyword)} failed ..."
          p e.message
          return
        end
      end

      response = response.force_encoding("UTF-8")
      p response
      title_pattern = /<h3 class="t.+?">\s*?<a.+?target="_blank"\s*?>(.+?)<\/a>\s*?<\/h3>/
      domain_pattern = /<span class="g">(.+?)&nbsp;(19|20)\d{2}-\d{2}-\d{2}&nbsp;<\/span>/

      titles = response.scan(title_pattern)
      domains = response.scan(domain_pattern)
      p "============================="
      p titles
      p domains
      p "============================="

      kw_id = RubyCrawler::Keyword.first(keyword: keyword).id
      titles.each_with_index do |title, index|
        title = title.first.gsub("<em>", "").gsub("</em>", "").gsub(" ", "")
        domain = URI.parse(domains[index].first).host
        p title
        p domain
        p kw_id

        RubyCrawler::KeywordTitle.insert(keyword_id: kw_id, title: title, domain: domain)
      end
    end
  end
end
