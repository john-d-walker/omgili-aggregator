# redis_pusher.rb

require 'redis'
require 'observer'

class RedisPusher
  include Observable

  attr_reader :redis, :list_name

  def initialize(list_name)
    @redis = Redis.new
    @list_name = list_name
  end

  def push(element)
    if (element.nil?)
      return nil
    end

    @redis.rpush(@list_name, element)

    changed
    notify_observers(element.size)
  end

  def update(element)
    push(element)
  end
end

