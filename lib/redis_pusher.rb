# redis_pusher.rb

require 'redis'

class RedisPusher
  attr_reader :redis
  def initialize
    @redis = Redis.new
  end

  def single_push(element, list_name)

  end

  def pipeline_push(elements, list_name)

  end
end

