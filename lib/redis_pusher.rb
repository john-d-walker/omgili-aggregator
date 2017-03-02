# redis_pusher.rb

require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'observer'

# Pushes data to a Redis list.
class RedisPusher
  include Observable

  attr_reader :redis, :list_name

  def initialize(list_name)
    @list_name = list_name
    @redis = Redis.new
    @redis.ping
  rescue StandardError => e
    e.message
    puts 'Cannot connect to Redis server.'
    puts 'Please troubleshoot the Redis server connection and try again.'
    abort
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
