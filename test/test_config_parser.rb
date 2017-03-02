# test_config_parser.rb

require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require_relative '../lib/config_parser'

# Test cases for the ConfigParser module.
class TestConfigParser < Minitest::Test
  attr_reader :default_config, :test_config

  def setup
    @default_config = { host: '127.0.0.1', port: 6379, db: 1,
                        require_pass: false, threads: 2, download_limit: 1024 }

    @test_config = { host: '10.0.0.1', port: 2345, db: 15,
                     require_pass: true, threads: 4, download_limit: 4000 }
  end

  def test_default_values_returned_with_bad_path
    config = ConfigParser.configure_with('bad/path')
    assert_equal @default_config[:host], config[:host]
    assert_equal @default_config[:port], config[:port]
    assert_equal @default_config[:require_pass], config[:require_pass]
    assert_equal @default_config[:download_limit], config[:download_limit]
  end

  def test_contents_are_loaded_with_good_path
    config = ConfigParser.configure_with('test/files/test_config.yaml')
    assert_equal @test_config[:host], config[:host]
    assert_equal @test_config[:port], config[:port]
    assert_equal @test_config[:require_pass], config[:require_pass]
    assert_equal @test_config[:download_limit], config[:download_limit]
  end
end
