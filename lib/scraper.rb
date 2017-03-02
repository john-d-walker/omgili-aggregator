# scraper.rb
require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'

# link: full download link for zip. size: in MB
ZipData = Struct.new(:link, :size)

# Scrapes data from the omgili.com feed.
class Scraper
  attr_reader :html, :zip_data

  FEED_URL = 'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/'.freeze

  def initialize
    @html = Nokogiri::HTML(open(FEED_URL))
    @zip_data = []
  end

  # Returns an array of ZipData.
  def scrape
    # Data starts at tr[3] and ends at tr[n-2].
    (3..@html.css('tr').length - 2).each do |i|
      row = @html.css('tr')[i]
      @zip_data.push(ZipData.new(FEED_URL + row.css('a').text,
                                 format_file_size(row.css('td')[2])))
    end
    @zip_data
  end

  # Removes trailing characters and casts to float.
  def format_file_size(size)
    size.text[0...-1].to_f
  end
end
