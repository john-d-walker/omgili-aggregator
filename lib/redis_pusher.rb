# redis_pusher.rb

require 'redis'
require 'observer'

# Pushes data to a Redis list.
class RedisPusher
  include Observable

  attr_reader :redis, :list_name

  def initialize(list_name)
    @redis = Redis.new
    @list_name = list_name
  end

  def push(element)
    return nil if element.nil?

    @redis.rpush(@list_name, element)

    changed
    notify_observers(element.size)
  end

  def update(element)
    push(element)
  end
end
