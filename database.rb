#!/usr/bin/env ruby
# encoding: utf-8

require 'sequel'
require './config'

module RubyCrawler

  CACHE = {}
  Sequel::Model.plugin :caching, CACHE, ttl: 60

  #db_options = {max_connections: 5, encoding: 'UTF-8'}
  db_options = {}

  username = Config.get('db.user')
  password = Config.get('db.pass')
  dbhost = Config.get('db.host')
  db = Config.get('db.database')
  DB = Sequel.connect("mysql2://#{username}:#{password}@#{dbhost}/#{db}", db_options)
  DB.convert_tinyint_to_bool = false

end
