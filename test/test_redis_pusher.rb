# test_redis_pusher.rb

require 'minitest/autorun'
require 'redis'
require_relative '../lib/redis_pusher.rb'

class TestRedisPusher < Minitest::Test
  attr_reader :redis_pusher

  def setup
    @redis_pusher = RedisPusher.new
  end

  def test_single_push
    test_string = "Hello, Redis!"
    redis_list_name = "SINGLE_TEST"
    @redis_pusher.push(test_string, redis_list_name)
    assert_equal test_string, Redis.new.lrange(redis_list_name, 0, -1)[0]
    #reset
    Redis.new.DEL(redis_list_name, 0, -1)
  end

  def test_multi_push
    test_array = ["test1", "test2", "test3"]
    redis_list_name = "PIPE_TEST"
    @redis_pusher.push(test_array, redis_list_name)
    assert_equal test_array, Redis.new.lrange(redis_list_name, 0, -1)
    # reset
    Redis.new.DEL(redis_list_name, 0, -1)
  end
end

