# test_scraper.rb

require 'minitest/autorun'
require_relative '../lib/scraper'

class TestScraper < Minitest::Test
  def setup
    @scraper = Scraper.new
  end

  def test_that_zip_file_names_are_valid
    @scraper.scrape.each do |data|
      assert_equal true, data.name =~ %r/\d+.zip/
    end
  end

  def test_that_zip_file_sizes_are_floats
    @scraper.scrape.each do |data|
      assert_equal 'Float', data.size.class
    end
  end
end

