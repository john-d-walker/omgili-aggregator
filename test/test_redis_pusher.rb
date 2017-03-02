# test_redis_pusher.rb

require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'redis'
require_relative '../lib/redis_pusher.rb'

# Test cases for the RedisPusher class.
class TestRedisPusher < Minitest::Test
  attr_reader :redis_pusher, :redis_list_name

  def setup
    @redis_list_name = 'TEST'
    @redis_pusher = RedisPusher.new(@redis_list_name)
  end

  def test_single_push
    test_string = 'Hello, Redis!'
    @redis_pusher.push(test_string)
    assert_equal test_string, Redis.new.lrange(@redis_list_name, 0, -1)[0]
    # reset
    Redis.new.DEL(redis_list_name, 0, -1)
  end

  def test_multi_push
    test_array = %w(test1 test2 test3)
    @redis_pusher.push(test_array)
    assert_equal test_array, Redis.new.lrange(@redis_list_name, 0, -1)
    # reset
    Redis.new.DEL(redis_list_name, 0, -1)
  end
end
