# test_omgili_aggregator.rb

require 'minitest/autorun'
require_relative '../lib/omgili_aggregator.rb'

class TestOmgiliAggregator < Minitest::Test
  attr_reader :omgili_aggregator, :array_1, :array_2, :array_3

  def setup
    @omgili_aggregator = OmgiliAggregator.new
    @old_links = %w[a b c]
    @new_links = %w[a b c d]
  end

  def test_that_old_links_removed_from_new
    assert_equal ['d'],
      @omgili_aggregator.generate_download_list(@old_links, @new_links)
  end

  def test_when_both_arrays_equal_returns_empty_array
    assert_equal [],
      @omgili_aggregator.generate_download_list(@old_links, @old_links)
  end

  def test_that_array_is_split_into_four_parts
    assert_equal [['a'], ['b'], ['c'], ['d']],
      @omgili_aggregator.split_download_list(@new_links)
  end
end

