# redis_pusher.rb

require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'observer'
require 'highline/import'

# Pushes data to a Redis list.
class RedisPusher
  include Observable

  attr_reader :redis, :list_name

  def initialize(host, port, db, req_pass, list_name)
    @list_name = list_name
    @connection_settings = parse_connection_info(host, port, db, req_pass)
    @redis = Redis.new(@connection_settings)
    @redis.ping
  rescue StandardError => e
    puts e.message
    puts 'Cannot connect to Redis server.'
    puts 'Please troubleshoot the Redis server connection and try again.'
    abort
  end

  def parse_connection_info(host, port, db, req_pass)
    password = get_password if req_pass
    settings = {}
    if password.nil?
      settings['host'] = host
      settings['port'] = port
      settings['db'] = db
    else
      settings['url'] = "redis://:#{password}@#{host}:#{port}/#{db}"
    end

    settings
  end

  def get_password(prompt = 'Enter password for Redis server: ')
    ask(prompt) { |q| q.echo = false }
  end

  def push(element)
    return nil if element.nil?

    begin
      @redis.rpush(@list_name, element)
    rescue StandardError => e
      e.message
      puts 'Please troubleshoot the Redis server problem and try again.'
      abort
    end

    changed
    notify_observers(element.size)
  end

  def update(element)
    push(element)
  end
end
