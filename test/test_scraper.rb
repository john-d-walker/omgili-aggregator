# test_scraper.rb

require 'minitest/autorun'
require_relative '../lib/scraper'

class TestScraper < Minitest::Test
  def setup
    @scraper = Scraper.new
  end

  def test_that_zip_file_links_are_valid
    @scraper.scrape.each do |data|
      assert_equal 0,
        data.link =~ /http:\/\/feed.omgili.com\/5Rh5AMTrc4Pv\/mainstream\/posts\/\d+.zip/
    end
  end

  def test_that_zip_file_sizes_are_floats
    @scraper.scrape.each do |data|
      assert_equal 1.1.class, data.size.class
    end
  end
end

