#!/usr/bin/env ruby
# encoding: utf-8

require 'socket'
require './crawlers/keyword_crawler'
require './crawlers/keyword_title_crawler'

module RubyCrawler
  class ThreadPool
    def initialize(size)
      # 线程数
      @size = size
      # 初始化工作队列
      @jobs = Queue.new
      # 初始化线程池
      @pool = Array.new(@size) do |i|
        Thread.new do
          Thread.current[:id] = i
          p "threads #{i} started"

          qihu_socket, baidu_socket = init_sockets

          socket_map =
            {keyword: qihu_socket, title: baidu_socket}
          crawler_map =
            {keyword: RubyCrawler::KeywordCrawler, title: RubyCrawler::KeywordTitleCrawler}

          loop do
            type, keyword = @jobs.pop
            Thread.exit(0) if type == :shutdown
            crawler = crawler_map[type].new(keyword, socket_map[type], @jobs)
            retry_count = 3
            begin
              retry_count -= 1
              crawler.fetch
            rescue => e
              if retry_count > 0
                qihu_socket, baidu_socket = init_sockets
                retry
              end
            end
          end
        end
      end
    end

    def schedule(type, keyword)
      @jobs << [type, keyword]
    end

    def shutdown
      @size.times do
        schedule(:shutdown, nil)
      end
    end

    def join
      @pool.map(&:join)
    end

    def init_sockets
      qihu_socket =
        TCPSocket.new(Config.get('server.qihu.host'), Config.get('server.qihu.port'))
      baidu_socket =
        TCPSocket.new(Config.get('server.baidu.host'), Config.get('server.baidu.port'))
      [qihu_socket, baidu_socket]
    end
  end
end
