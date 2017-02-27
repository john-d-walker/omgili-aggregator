# redis_pusher.rb

require 'redis'

class RedisPusher
  attr_reader :redis
  def initialize
    @redis = Redis.new
  end

  def push(element, list_name)
    if (element.nil? || list_name.nil?)
      return nil
    end

    @redis.rpush(list_name, element)
  end
end

